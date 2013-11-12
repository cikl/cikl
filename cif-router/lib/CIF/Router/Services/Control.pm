package CIF::Router::Services::Control;
use parent 'CIF::Router::Service';

use strict;
use warnings;
use CIF::Router::Constants;
use Try::Tiny;
use CIF qw/debug/;

sub service_type { SVC_CONTROL }

# Should return 1 or 0
sub queue_should_autodelete {
  return 1;
}

# Should return 1 or 0
sub queue_is_durable {
  return 0;
}

sub new {
  # This actually wraps another service so that we can control it. 
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  return $self;
}

sub process {
  my $self = shift;
  my $payload = shift;
  my $err;
  my ($remote_hostinfo, $response, $encoded_response);
  try {
    $remote_hostinfo = $self->{encoder}->decode_hostinfo($payload);
  } catch {
    $err = shift;
  };

  if ($err) {
    die("Error decoding hostinfo: $err");
  }
  debug("Got ping: " . $remote_hostinfo->to_string());

  try {
    $response = CIF::Models::HostInfo->generate(
      {
        uptime => $self->uptime(),
        service_type => $self->name()
      });
  } catch {
    $err = shift;
  };

  if ($err) {
    die("Error generating hostinfo: $err");
  }

  try {
    $encoded_response = $self->{encoder}->encode_hostinfo($response);
  } catch {
    $err = shift;
  };

  if ($err) {
    die("Error encoding hostinfo: $err");
  }
  return($encoded_response, "pong", $self->{encoder}->content_type());
}

1;


