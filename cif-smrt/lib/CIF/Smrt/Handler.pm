package CIF::Smrt::Handler;

use strict;
use warnings;
use CIF::EventBuilder;
use CIF::Smrt::Broker;
use Config::Simple;
use Try::Tiny;
use AnyEvent;
use Coro;

use CIF qw/debug/;

sub new {
  my $class = shift;
  my $args = shift;
  my $self = {};
  bless $self, $class;

  # do this here, we'll do the setup within the sender_routine (thread)
  $self->{cif_config_filename} = $args->{'config'};

  $self->init_config();
  
  my $goback = $args->{'goback'} || $self->{smrt_config}->{'goback'} || 3;
  $goback = (time() - ($goback * 84600));
  $self->{goback} = $goback;

  $self->{apikey} = $args->{'apikey'} || $self->{smrt_config}->{'apikey'} || die('missing apikey');
  $self->{proxy} =  $args->{'proxy'}  || $self->{smrt_config}->{'proxy'};

  my $event_builder = CIF::EventBuilder->new(
    refresh => $args->{'refresh'},
    goback => $self->goback(),
    default_event_data => $args->{'default_event_data'} || {}
  );
  $self->{'event_builder'} = $event_builder;

  if($::debug){
    my $gb = DateTime->from_epoch(epoch => $goback);
    debug('goback: '.$gb);
  }    
    
  return $self;
}

sub event_builder {
    my $self = shift;
    return $self->{event_builder};
}

sub init_config {
  my $self = shift;
  my $config_file = $self->{cif_config_filename};

  my $config;
  my $err;
  try {
    $config = Config::Simple->new($config_file);
  } catch {
    $err = shift;
  };

  unless($config){
    die('unknown or missing config: '. $config_file);
  }
  if($err){
    my @errmsg;
    push(@errmsg,'something is broken in your local config: '.$config_file);
    push(@errmsg,'this is usually a syntax error problem, double check '.$config_file.' and try again');
    die(join("\n",@errmsg));
  }

  $self->{smrt_config} = $config->param(-block => 'cif_smrt');
}

sub fetchers {
  my $self = shift;
  return $self->{fetchers}->fetchers();
}

sub decoders {
  my $self = shift;
  return $self->{decoders};
}

sub parsers {
  my $self = shift;
  return $self->{parsers};
}

sub proxy {
  my $self = shift;
  return $self->{proxy};
}

sub apikey {
  my $self = shift;
  return $self->{apikey};
}

sub goback {
  my $self = shift;
  return $self->{goback};
}

sub get_client {
  my $self = shift;
  my $apikey = shift;
  my ($err,$client) = CIF::Client->new({
      config  => $self->{cif_config_filename},
      apikey  => $apikey,
    });

  if ($err) {
    die($err);
  }
  return($client);
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
      Coro::AnyEvent::sleep(1);
    }
    my $retref = $cv->recv();

    # auto-decode the content if need be
    $retref = $self->decode($retref);

    ## TODO MPR : This looks like a hack for the utf8 and CR stuff below.
    #return(undef,$ret) if($feedparser_config->{'cif'} && $feedparser_config->{'cif'} eq 'true');

    ## Commenting this out as I haven't run into any issues, yet.  
    # encode to utf8
    #$ret = encode_utf8($ret);
    
    # remove any CR's
    #$ret =~ s/\r//g;
    return($retref);
}


sub parse {
    my $self = shift;
    my $broker = shift;

    my $content_ref = $self->fetch();
    
    my $return = $self->get_parser()->parse($content_ref, $broker);
    return(undef);
}

# Just pass things through. This can be overridden by subclasses.
sub decode {
    my $self = shift;
    my $content_ref = shift;
    return $content_ref;
}


# Stuff that needs to be implemented

# Returns an instance of a fetcher. We will call fetcher->fetch()
sub get_fetcher {
    my $self = shift;
    die("get_fetcher() not implemented!");
}

# Returns an instance of a parser. We will call parser->parse($content_ref, $broker)
sub get_parser {
    my $self = shift;
    die("get_parser() not implemented!");
}

1;
