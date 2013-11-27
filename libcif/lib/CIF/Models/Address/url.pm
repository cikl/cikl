package CIF::Models::Address::url;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use CIF::MooseTypes;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'url' }

has '+value' => (
  isa => 'CIF::MooseTypes::Url',
  coerce => 1
);

sub as_string {
  my $self = shift;
  return $self->value->as_string();
}

__PACKAGE__->meta->make_immutable;
1;



