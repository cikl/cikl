package CIF::Models::Address::fqdn;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use CIF::MooseTypes;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'fqdn' }

has '+value' => (
  isa => 'CIF::MooseTypes::Fqdn',
  coerce => 1
);

__PACKAGE__->meta->make_immutable;
1;
