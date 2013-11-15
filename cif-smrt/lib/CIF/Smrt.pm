package CIF::Smrt;
use base 'Class::Accessor';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.99_03';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use CIF::Client;
use CIF::Smrt::Parsers;
use CIF::Smrt::Decoders;
use CIF::Smrt::Fetchers;
use Regexp::Common qw/net URI/;
use Regexp::Common::net::CIDR;
use Encode qw/encode_utf8/;
use Data::Dumper;
use File::Type;
use Module::Pluggable require => 1;
use URI::Escape;
use Try::Tiny;
use CIF::Smrt::FeedParserConfig;
use CIF::Smrt::Broker;
use CIF::EventBuilder;
use AnyEvent;
use Coro;

use Net::SSLeay;
Net::SSLeay::SSLeay_add_ssl_algorithms();

use CIF qw/generate_uuid_url generate_uuid_random is_uuid debug normalize_timestamp/;

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(qw(
    smrt_config feeds_config feeds 
    entries defaults feed feedparser_config load_full goback 
    wait_for_server name instance 
    batch_control cif_config_filename apikey
    proxy
));

sub new {
    my $class = shift;
    my $args = shift;
    
    my $self = {};
    bless($self,$class);

    $self->{decoders} = CIF::Smrt::Decoders->new();
    $self->{parsers} = CIF::Smrt::Parsers->new();
    $self->{fetchers} = CIF::Smrt::Fetchers->new();
      
    my ($err,$ret) = $self->init($args);
    return($err) if($err);

    return (undef,$self);
}

sub init {
    my $self = shift;
    my $args = shift;

    # do this here, we'll do the setup within the sender_routine (thread)
    $self->set_cif_config_filename($args->{'config'});

    my ($err,$ret) = $self->init_config();
    return($err) if($err);
      
    ($err,$ret) = $self->init_rules($args->{'rules'}, $args->{'feed'});
    return($err) if($err);

    $self->set_goback(          $args->{'goback'}           || $self->get_smrt_config->{'goback'}            || 3);
    $self->set_wait_for_server( $args->{'wait_for_server'}  || $self->get_smrt_config->{'wait_for_server'}   || 0);
    $self->set_batch_control(   $args->{'batch_control'}    || $self->get_smrt_config->{'batch_control'}     || 2500); # arbitrary
    $self->set_apikey(          $args->{'apikey'}           || $self->get_smrt_config->{'apikey'}            || return('missing apikey'));
    $self->set_proxy(           $args->{'proxy'}            || $self->get_smrt_config->{'proxy'});
   
    $self->set_goback(time() - ($self->get_goback() * 84600));

    my $fpc = $self->get_feedparser_config();

    my $event_builder = CIF::EventBuilder->new(
      refresh => $fpc->{'refresh'},
      goback => $self->get_goback(),
      default_event_data => $fpc->default_event_data()
    );
    $self->{'event_builder'} = $event_builder;

    
    if($::debug){
        my $gb = DateTime->from_epoch(epoch => $self->get_goback());
        debug('goback: '.$gb);
    }    
    
    ## TODO -- this isnt' being passed to the plugins, the config is
    $self->set_name(        $args->{'name'}     || $self->get_smrt_config->{'name'}      || 'localhost');
    $self->set_instance(    $args->{'instance'} || $self->get_smrt_config->{'instance'}  || 'localhost');
    
    $self->init_feeds();

    return(undef,1);
}

sub get_client {
  my $self = shift;
  my ($err,$client) = CIF::Client->new({
      config  => $self->get_cif_config_filename(),
      apikey  => $self->get_apikey(),
    });

  if ($err) {
    die($err);
  }
  return($client);
}

sub lookup_decoder {
  my $self = shift;
  my $mime_type = shift;
  return $self->{decoders}->lookup($mime_type);
}

sub lookup_parser {
  my $self = shift;
  my $parser_name = shift;
  my $parser_class = $self->{parsers}->get($parser_name);
  if (!defined($parser_class)) {
    die("Could not find a parser for parser=$parser_name. Valid parsers: " . $self->{parsers}->valid_parser_names_string);
  }
  return $parser_class;
}

sub init_config {
    my $self = shift;
    my $config_file = $self->get_cif_config_filename();

    
    my $config;
    my $err;
    try {
        $config = Config::Simple->new($config_file);
    } catch {
        $err = shift;
    };
    
    unless($config){
        return('unknown or missing config: '. $config_file);
    }
    if($err){
        my @errmsg;
        push(@errmsg,'something is broken in your local config: '.$config_file);
        push(@errmsg,'this is usually a syntax error problem, double check '.$config_file.' and try again');
        return(join("\n",@errmsg));
    }

    $self->set_smrt_config(          $config->param(-block => 'cif_smrt'));
    $self->set_feeds_config(    $config->param(-block => 'cif_feeds'));
    
    return(undef,1);
}

sub init_rules {
    my $self = shift;
    my $rulesfile = shift;
    my $feed_name = shift;
    
    my $rules_config;
    my ($err,@errmsg);
    try {
        $rules_config = CIF::Smrt::FeedParserConfig->new($rulesfile, $feed_name);
    } catch {
        $err = shift;
    };
    
    return($err) if($err);
    $self->set_feedparser_config($rules_config);
    return(undef,1);
}

sub init_feeds {
    my $self = shift;
    
    my $feeds = $self->get_feeds_config->{'enabled'} || return;
    $self->set_feeds($feeds);
}

sub fetch_feed { 
    my $self = shift;
    my $f = shift;
    my $cv = AnyEvent->condvar;

    async {
      try {
        $cv->send($self->_fetch_feed($f));
      } catch {
        $cv->croak(shift);
      };
    };
    while (!($cv->ready())) {
      Coro::AnyEvent::sleep 1;
    }
    my $retref = $cv->recv();

    # auto-decode the content if need be
    $retref = $self->_decode($retref,$f);

    ## TODO MPR : This looks like a hack for the utf8 and CR stuff below.
    #return(undef,$ret) if($f->{'cif'} && $f->{'cif'} eq 'true');

    ## Commenting this out as I haven't run into any issues, yet.  
    # encode to utf8
    #$ret = encode_utf8($ret);
    
    # remove any CR's
    #$ret =~ s/\r//g;
    delete($f->{'feed'});
    
    return(undef,$retref);
}

# we do this sep cause it's in a thread
# this gets around memory leak issues and TLS threading issues with Crypt::SSLeay, etc
sub _fetch_feed {
    my $self = shift;
    my $f = shift;
    unless($f->{'feed'}) {
      die("no feed config provided!");
    }
    
    # MPR TODO : Fix up this key/val replacing stuff.
#    foreach my $key (keys %$f){
#        foreach my $key2 (keys %$f){
#            if($f->{$key} =~ /<$key2>/){
#                $f->{$key} =~ s/<$key2>/$f->{$key2}/g;
#            }
#        }
#    }
    foreach my $p ($self->{fetchers}->fetchers()){
        debug("Trying to fetch with $p") if($::debug);
        my ($err,$ret) = $p->fetch($f);
        if($err) {
          die("ERROR! $err");
        }
        
        # we don't want to error out if there's just no content
        unless(defined($ret)) {
          next;
        }
        debug("Succesfully fetched data using $p") if($::debug);
        return(\$ret);
    }
    die('ERROR: could not fetch feed');
}


sub parse {
    my $self = shift;
    my $broker = shift;
    my $f = $self->get_feedparser_config();
    
    if($self->get_proxy()){
        $f->{'proxy'} = $self->get_proxy();
    }
    die 'feed does not exist' unless($f->{'feed'});
    debug('fetching feed: '.$f->{'feed'}) if($::debug);
    if($self->get_cif_config_filename()){
        $f->{'client_config'} = $self->get_cif_config_filename();
    }
    my ($err,$content_ref) = $self->fetch_feed($f);
    die($err) if($err);
    
    my $parser_class = $self->lookup_parser($f->{parser});

    debug("Parser class: $parser_class");

    my $parser = $parser_class->new($f);
    my $return = $parser->parse($content_ref, $broker);
    return(undef);
}

sub _decode {
    my $self = shift;
    my $dataref = shift;
    my $f = shift;

    my $ft = File::Type->new();
    my $t = $ft->mime_type($$dataref);
    my $decoder = $self->lookup_decoder($t);
    unless($decoder) {
      debug("Don't know how to decode $t");
      return $dataref;
    }
    return $decoder->decode($dataref, $f);
}

sub process {
    my $self = shift;
    my $args = shift;
    my ($err, $ret);
    
    my $client = $self->get_client();
    my $guid = $self->get_feedparser_config->{'guid'};
    my $emit_cb = sub {
      my $event = shift;
      ($err, $ret) = $client->submit($event);    
      if ($err) {
        die($err);
      }
    };

    my $broker = CIF::Smrt::Broker->new(
      emit_cb => $emit_cb, 
      builder => $self->{event_builder}
    );
    try {
      my ($err) = $self->parse($broker);
      if ($err) {
        die($err);
      }
    } catch {
      $err = shift;
    } finally {
      if ($client) {
        $client->shutdown();
      }
    };
    if ($err) {
      return($err);
    }

    if($::debug) {
      debug('records to be processed: '.$broker->count() . ", too old: " . $broker->count_too_old());
    }

    if($broker->count() == 0){
      if ($broker->count_too_old() != 0) {
        debug('your goback is too small, if you want records, increase the goback time') if($::debug);
      }
      return (undef, 'no records');
    }

    return(undef);
}

1;
