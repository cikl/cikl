package CIF::Router::Server;

use strict;
use warnings;
use AnyEvent;
use Coro;
use CIF::Router::Transport;
use Config::Simple;
use CIF::Router;
use Try::Tiny;
use CIF::Encoder::JSON;
use Sys::Hostname;

use CIF qw/debug init_logging/;

use constant {
  SUBMISSION => 1,
  QUERY => 2,
  PING => 3
};

sub new {
    my $class = shift;
    my $type = shift;
    my $config = shift;

    my $self = {};
    bless($self,$class);

    $self->{starttime} = time();

    $self->{config} = Config::Simple->new($config) || die("Could not load config file: '$config'");
    $self->{server_config} = $self->{config}->param(-block => 'router_server');

    $self->{encoder} = CIF::Encoder::JSON->new();

    init_logging($self->{server_config}->{'debug'} || 0);

    # Initialize the router.
    my ($err,$router) = CIF::Router->new({
        config  => $self->{config},
      });
    if($err){
      ## TODO -- set debugging variable
      die $err;
    }

    $self->{router} = $router;

    my $driver_name = $self->{server_config}->{driver} || "RabbitMQ";
    my $driver_config = $self->{config}->param(-block => ('router_server_' . lc($driver_name)));
    my $driver_class = "CIF::Router::Transport::" . $driver_name;

    $self->{commit_interval} = $self->{server_config}->{commit_interval} || 2;


    my $driver;
    try {
      $driver = $driver_class->new($driver_config);
    } catch {
      $err = shift;
      die "Driver ($driver_class) failed to load: $err";
    };

    $self->{driver} = $driver;

    if ($type == SUBMISSION) {
      my $cb = sub {$self->process_submission(@_);};
      $driver->setup_submission_processor($cb);

    } elsif ($type == QUERY) {
      my $cb = sub {$self->process_query(@_);};
      $driver->setup_query_processor($cb);

    } elsif ($type == PING) {
      my $cb = sub {$self->process_ping(@_);};
      $driver->setup_ping_processor($cb);
    } else {
      die "Unknown type: $type";
    }


    return($self);
}

sub uptime {
  my $self = shift;
  return time() - $self->{starttime};
}

sub process_query {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($query, $results, $encoded_results);
  try {
    $query = $self->{encoder}->decode_query($payload);
    $results = $self->{router}->process_query($query);
    $encoded_results = $self->{encoder}->encode_query_results($results);
  } catch {
    my $err = shift;
    return($err, "submission_error", 'text/plain');
  };
  return($encoded_results, "query_response", $self->{encoder}->content_type());
}

sub process_ping {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($remote_hostinfo, $response, $encoded_response);
  try {
    $remote_hostinfo = $self->{encoder}->decode_hostinfo($payload);
    debug("Got ping: " . $remote_hostinfo->to_string());
    $response = CIF::Models::HostInfo->generate({uptime => $self->uptime()});
    $encoded_response = $self->{encoder}->encode_hostinfo($response);
  } catch {
    my $err = shift;
    debug("Got an error: $err");
    return($err, "ping_error", 'text/plain');
  };
  return($encoded_response, "pong", $self->{encoder}->content_type());
}

sub process_submission {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($submission, $results);
  try {
    $submission = $self->{encoder}->decode_submission($payload);
    $results = $self->{router}->process_submission($submission);
  } catch {
    my $err = shift;
    return($err, "submission_error", 'text/plain');
  };
  $self->schedule_flush();
  return($results, "submission_response", $self->{encoder}->content_type());
}

sub schedule_flush {
  my $self = shift;
  if (!defined($self->{flush_timer})) {
    # Create a timer that will flush two seconds after our first message 
    # comes in.
    my $cb = sub {
      $self->{router}->flush();
      $self->{flush_timer} = undef;
    };
    $self->{flush_timer} = AnyEvent->timer(after => $self->{commit_interval}, 
      cb => $cb);
  }
}

sub run {
    my $self = shift;

    $self->{driver}->start();

    $self->{cv} = AnyEvent->condvar;

    my $thr = async {
      $self->{cv}->recv();
      $self->{cv} = undef;
    };

    while ( defined( $self->{cv} ) ) {
      Coro::AnyEvent::sleep 1;
    }

    $self->{driver}->stop();
}

sub stop {
    my $self = shift;
    if (my $cv = $self->{cv}) {
      debug("Stopping");
      $cv->send(undef);
    }
}

sub shutdown {
    my $self = shift;

    if ($self->{driver}) {
      $self->{driver}->shutdown();
      $self->{driver} = undef;
    }
}

1;
