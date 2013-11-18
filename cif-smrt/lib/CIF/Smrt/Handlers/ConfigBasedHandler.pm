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
    my $feedparser_config = $args->{feedparser_config};
    $args->{refresh} = $feedparser_config->{refresh};
    $args->{default_event_data} = $feedparser_config->default_event_data();

    my $self = $class->SUPER::new($args);

    $self->{feedparser_config} = $feedparser_config;
    
    if($self->proxy){
        $feedparser_config->{'proxy'} = $self->proxy;
    }

    return $self;
}


sub fetch { 
    my $self = shift;
    my $cv = AnyEvent->condvar;
    my $fetcher = $self->get_fetcher();

    async {
      try {
        $cv->send($fetcher->fetch());
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
    return($retref);
}

sub get_fetcher {
    my $self = shift;
    my $feedparser_config = $self->{feedparser_config};
    my $feedurl = URI->new($feedparser_config->feed());
    my $fetcher_class = $self->lookup_fetcher($feedurl);
    if (!defined($fetcher_class)) {
      die("Could not determine fetcher");
    }

    return $fetcher_class->new($feedurl, $feedparser_config);
}

sub get_parser {
    my $self = shift;
    my $parser_class = $self->lookup_parser($self->{feedparser_config}->parser);
    return $parser_class->new($self->{feedparser_config});
}

sub parse {
    my $self = shift;
    my $broker = shift;

    my $content_ref = $self->fetch();
    
    my $return = $self->get_parser()->parse($content_ref, $broker);
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
      builder => $self->event_builder()
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

