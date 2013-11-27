package CIF::Models::AddressRole;
use strict;
use warnings;
use Moose::Role;
use namespace::autoclean;

requires 'type';

has 'value' => (
  is => 'rw',
  isa => 'Str',
  required => 1
);

sub as_string {
  my $self = shift;
  return $self->value;
}

1;
