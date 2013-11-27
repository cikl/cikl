package CIF::Models::Address::email;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use namespace::autoclean;
use CIF::MooseTypes;
with 'CIF::Models::AddressRole';

sub type { 'email' }

has '+value' => (
  isa => 'CIF::MooseTypes::Email',
  coerce => 1
);

__PACKAGE__->meta->make_immutable;
1;
