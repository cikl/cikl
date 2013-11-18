package CIF::Smrt::Handlers::ConfigBasedHandler;
use base 'CIF::Smrt::Handler';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.99_03';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use CIF::Client;
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
use URI;
use AnyEvent;
use Coro;

use Net::SSLeay;
Net::SSLeay::SSLeay_add_ssl_algorithms();

use CIF qw/debug/;

sub new {
    my $class = shift;
    my $args = shift;
    my $self = $class->SUPER::new($args);

    $self->{feedparser_config} = $args->{feedparser_config};

    return $self;
}

sub _event_builder {
    my $self = shift;
    if ($self->{event_builder}) {
      return $self->{event_builder};
    }

    my $feedparser_config = $self->{feedparser_config};

    my $event_builder = CIF::EventBuilder->new(
      refresh => $feedparser_config->{'refresh'},
      goback => $self->goback(),
      default_event_data => $feedparser_config->default_event_data()
    );
    $self->{'event_builder'} = $event_builder;
}

sub fetch_feed { 
    my $self = shift;
    my $feedparser_config = shift;
    my $cv = AnyEvent->condvar;

    async {
      try {
        $cv->send($self->_fetch_feed());
      } catch {
        $cv->croak(shift);
      };
    };
    while (!($cv->ready())) {
      Coro::AnyEvent::sleep 1;
    }
    my $retref = $cv->recv();

    # auto-decode the content if need be
    $retref = $self->_decode($retref);

    ## TODO MPR : This looks like a hack for the utf8 and CR stuff below.
    #return(undef,$ret) if($feedparser_config->{'cif'} && $feedparser_config->{'cif'} eq 'true');

    ## Commenting this out as I haven't run into any issues, yet.  
    # encode to utf8
    #$ret = encode_utf8($ret);
    
    # remove any CR's
    #$ret =~ s/\r//g;
    return(undef,$retref);
}

# we do this sep cause it's in a thread
# this gets around memory leak issues and TLS threading issues with Crypt::SSLeay, etc
sub _fetch_feed {
    my $self = shift;
    my $feedparser_config = $self->{feedparser_config};
    unless($feedparser_config->{'feed'}) {
      die("no feed config provided!");
    }
    
    # MPR TODO : Fix up this key/val replacing stuff.
#    foreach my $key (keys %$feedparser_config){
#        foreach my $key2 (keys %$feedparser_config){
#            if($feedparser_config->{$key} =~ /<$key2>/){
#                $feedparser_config->{$key} =~ s/<$key2>/$feedparser_config->{$key2}/g;
#            }
#        }
#    }
    my $feedurl = URI->new($feedparser_config->feed());
    my $fetcher_class = $self->lookup_fetcher($feedurl);
    if (!defined($fetcher_class)) {
      die("Could not determine fetcher");
    }

    my $fetcher = $fetcher_class->new($feedparser_config);
    my ($err, $ret) = $fetcher->fetch($feedurl);
    if ($err) {
      die($err);
    }
    return \$ret;
}


sub parse {
    my $self = shift;
    my $broker = shift;
    my $feedparser_config = $self->{feedparser_config};
    
    if($self->{proxy}){
        $feedparser_config->{'proxy'} = $self->{proxy};
    }
    die 'feed does not exist' unless($feedparser_config->{'feed'});
    debug('fetching feed: '.$feedparser_config->{'feed'}) if($::debug);
    if($self->{cif_config_filename}){
        $feedparser_config->{'client_config'} = $self->{cif_config_filename};
    }
    my ($err,$content_ref) = $self->fetch_feed();
    die($err) if($err);
    
    my $parser_class = $self->lookup_parser($feedparser_config->{parser});

    debug("Parser class: $parser_class");

    my $parser = $parser_class->new($feedparser_config);
    my $return = $parser->parse($content_ref, $broker);
    return(undef);
}

sub _decode {
    my $self = shift;
    my $dataref = shift;
    my $feedparser_config = $self->{feedparser_config};

    my $ft = File::Type->new();
    my $t = $ft->mime_type($$dataref);
    my $decoder = $self->lookup_decoder($t);
    unless($decoder) {
      debug("Don't know how to decode $t");
      return $dataref;
    }
    return $decoder->decode($dataref, $feedparser_config);
}

sub process {
    my $self = shift;
    my ($err, $ret);
    
    my $client = $self->get_client($self->apikey());
    my $emit_cb = sub {
      my $event = shift;
      ($err, $ret) = $client->submit($event);    
      if ($err) {
        die($err);
      }
    };

    my $broker = CIF::Smrt::Broker->new(
      emit_cb => $emit_cb, 
      builder => $self->_event_builder()
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

