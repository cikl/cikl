package CIF::Router::Services::Control;
use strict;
use warnings;
use CIF::Router::ServiceRole;
use CIF::Router::Constants;
use Try::Tiny;
use CIF qw/debug/;
use Mouse;

with 'CIF::Router::ServiceRole';

use namespace::autoclean;

sub service_type { CIF::Router::Constants::SVC_CONTROL }

# Should return 1 or 0
sub queue_should_autodelete {
  return 1;
}

# Should return 1 or 0
sub queue_is_durable {
  return 0;
}

sub process {
  my $self = shift;
  my $payload = shift;
  my $err;
  my ($remote_hostinfo, $response, $encoded_response);
  try {
    $remote_hostinfo = $self->codec->decode_hostinfo($payload);
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
    $encoded_response = $self->codec->encode_hostinfo($response);
  } catch {
    $err = shift;
  };

  if ($err) {
    die("Error encoding hostinfo: $err");
  }
  return($encoded_response, "pong", $self->codec->content_type());
}

__PACKAGE__->meta->make_immutable();

1;


