package Cikl::Router::Services::Control;
use strict;
use warnings;
use Cikl::Router::ServiceRole;
use Cikl::Router::Constants;
use Cikl qw/debug/;
use Mouse;

with 'Cikl::Router::ServiceRole';

use namespace::autoclean;

sub service_type { Cikl::Router::Constants::SVC_CONTROL }

sub decode_payload {
  my $self = shift;
  my $payload = shift;
  return $self->codec->decode_hostinfo($payload);
}

sub do_work {
  my $self = shift;
  my $remote_hostinfo = shift;

  return  Cikl::Models::HostInfo->generate(
    {
      uptime => $self->uptime(),
      service_type => $self->name()
    });
}

sub encode_response {
  my $self = shift;
  my $results = shift;
  return $self->codec->encode_hostinfo($results);
}

use constant RESPONSE_TYPE => "pong";
sub response_type {
  return RESPONSE_TYPE;
}

__PACKAGE__->meta->make_immutable();

1;


