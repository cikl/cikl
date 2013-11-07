package CIF::Smrt;
use base 'Class::Accessor';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.99_03';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# default severity mapping
use constant DEFAULT_SEVERITY_MAP => {
    botnet      => 'high',
};

use CIF::Client;
use CIF::Smrt::Parsers;
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
use CIF::Smrt::EventNormalizer;
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
    severity_map proxy
));

my @preprocessors = __PACKAGE__->plugins();
@preprocessors = grep(/Preprocessor::[0-9a-zA-Z_]+$/,@preprocessors);

sub new {
    my $class = shift;
    my $args = shift;
    
    my $self = {};
    bless($self,$class);
      
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

    my $event_normalizer = CIF::Smrt::EventNormalizer->new({
      refresh => $self->get_feedparser_config->{'refresh'},
      severity_map => $self->get_severity_map(),
      goback => $self->get_goback()
    });

    $self->{'event_normalizer'} = $event_normalizer;
    
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
    
    my $map = $config->param(-block => 'cif_smrt_severity');
    $map = DEFAULT_SEVERITY_MAP() unless(keys %$map);
    
    $self->set_severity_map($map);
    
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

sub pull_feed { 
    my $f = shift;
    my $cv = AnyEvent->condvar;

    async {
      my $r;
      try {
        $r = _pull_feed($f);
      } catch {
        $cv->croak(shift);
      };
      $cv->send($r);
    };
    while (!($cv->ready())) {
      Coro::AnyEvent::sleep 1;
    }
    my $ret = $cv->recv();

    # auto-decode the content if need be
    $ret = _decode($ret,$f);

    return(undef,$ret) if($f->{'cif'} && $f->{'cif'} eq 'true');

    # encode to utf8
    $ret = encode_utf8($ret);
    
    # remove any CR's
    $ret =~ s/\r//g;
    delete($f->{'feed'});
    
    return(undef,$ret);
}

# we do this sep cause it's in a thread
# this gets around memory leak issues and TLS threading issues with Crypt::SSLeay, etc
sub _pull_feed {
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
    my @pulls = __PACKAGE__->plugins();
    @pulls = sort grep(/::Pull::/,@pulls);
    foreach my $p (@pulls){
        my ($err,$ret) = $p->pull($f);
        if($err) {
          die("ERROR! $err");
        }
        
        # we don't want to error out if there's just no content
        unless(defined($ret)) {
          debug("No data!");
          next;
        }
        return($ret);
    }
    die('ERROR: could not pull feed');
}


## TODO -- turn this into plugins
sub parse {
    my $self = shift;
    my $broker = shift;
    my $f = $self->get_feedparser_config();
    
    if($self->get_proxy()){
        $f->{'proxy'} = $self->get_proxy();
    }
    die 'feed does not exist' unless($f->{'feed'});
    debug('pulling feed: '.$f->{'feed'}) if($::debug);
    if($self->get_cif_config_filename()){
        $f->{'client_config'} = $self->get_cif_config_filename();
    }
    my ($err,$content) = pull_feed($f);
    die($err) if($err);
    
    my $parser_class;
    ## TODO -- this mess will be cleaned up and plugin-ized in v2
    if(my $d = $f->{'delimiter'}){
        $parser_class = "CIF::Smrt::Parsers::ParseDelim";
    } else {
        # try to auto-detect the file
        debug('testing...');
        ## todo -- very hard to detect iodef-pb strings
        # might have to rely on base64 encoding decode first?
        ## TODO -- pull this out
        if(($f->{'driver'} && $f->{'driver'} eq 'xml') || $content =~ /^(<\?xml version=|<rss version=)/){
            if($content =~ /<rss version=/ && !$f->{'nodes'}){
                $parser_class = "CIF::Smrt::Parsers::ParseRss";
            } else {
                $parser_class = "CIF::Smrt::Parsers::ParseXml";
            }
        } elsif($content =~ /^\[?{/){
            ## TODO -- remove, legacy
            $parser_class = "CIF::Smrt::Parsers::ParseJson";
        } elsif($content =~ /^#?\s?"[^"]+","[^"]+"/ && !$f->{'regex'}){
            # ParseCSV only works on strictly formated CSV files
            # o/w you should be using ParseDelim and specifying the "delimiter" field
            # in your config
            $parser_class = "CIF::Smrt::Parsers::ParseCsv";
        } else {
            $parser_class = "CIF::Smrt::Parsers::ParseTxt";
        }
    }

    if (!defined($parser_class)) {
        die("Could not initialize a parser class!");
    }

    my $parser = $parser_class->new($f);
    my $return = $parser->parse($content, $broker);
    return(undef);
}

sub _decode {
    my $data = shift;
    my $f = shift;

    my $ft = File::Type->new();
    my $t = $ft->mime_type($data);
    my @plugs = __PACKAGE__->plugins();
    @plugs = grep(/Decode/,@plugs);
    foreach(@plugs){
        if(my $ret = $_->decode($data,$t,$f)){
            return($ret);
        }
    }
    return $data;
}

sub process {
    my $self = shift;
    my $args = shift;
    
    my $client = $self->get_client();
    my $guid = $self->get_feedparser_config->{'guid'};
    my $emit_cb = sub {
      my $event = shift;
      my ($err, $ret) = $client->submit($guid, $event);    
      if ($err) {
        die($err);
      }
    };

    my $broker = CIF::Smrt::Broker->new($self->{event_normalizer}, $emit_cb);
    try {
      my ($err) = $self->parse($broker);
      if ($err) {
        die($err);
      }
    } catch {
      my $e = shift;
      return($e);
    } finally {
      if ($client) {
        $client->shutdown();
      }
    };

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
