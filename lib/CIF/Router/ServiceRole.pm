package CIF::Router::ServiceRole;

use strict;
use warnings;
use CIF qw/debug/;
use CIF::Router::Constants;
use Mouse::Role;
use namespace::autoclean;

has 'codec' => (
  is => 'ro',
  isa => 'CIF::Codecs::CodecRole',
  required => 1
);

has 'starttime' => (
  is => 'ro', 
  isa => 'Num',
  init_arg => undef,
  default => sub { time() }
);

requires "service_type";

sub name {
  my $class = shift;
  return CIF::Router::Constants::SVCNAMES->{$class->service_type()};
}

sub uptime {
  my $self = shift;
  return time() - $self->starttime();
}

sub checkpoint {
}

sub shutdown {
}

1;
