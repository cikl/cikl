package CIF::Models::HostInfo;
use strict;
use warnings;
require JSON;
use Moose;
use CIF::MooseTypes;
use namespace::autoclean;
use Sys::Hostname;

has 'hostname' => (
  is => 'rw',
  isa => 'CIF::MooseTypes::LowerCaseStr',
  required => 1
);

has 'process_id' => (
  is => 'rw',
  isa => 'Int',
  required => 1
);

has 'uptime' => (
  is => 'rw',
  isa => 'Int',
  required => 1
);

sub to_string {
  my $self = shift;
  return "Hostname: " . $self->hostname() . ", PID: " . $self->process_id() . ", Uptime: " . $self->uptime();
}

sub to_hash {
  my $self = shift;
  my $data = {};
  foreach my $key (keys %$self) {
    $data->{$key} = $self->{$key};
  }
  return $data;
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  return $class->new($data);
}

sub generate {
  my $class = shift;
  my $args = shift || {};
  $args->{hostname} = $args->{hostname} || hostname();
  $args->{process_id} = $args->{process_id} || $$ ;
  $args->{uptime} = $args->{uptime} || 0;
  $class->new($args);
}

__PACKAGE__->meta->make_immutable;

1;
