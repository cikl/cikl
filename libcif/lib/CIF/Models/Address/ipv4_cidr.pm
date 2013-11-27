package CIF::Models::Address::ipv4_cidr;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use CIF::MooseTypes;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'ipv4_cidr' }

has '+value' => (
  isa => 'CIF::MooseTypes::Ipv4Cidr'
);

__PACKAGE__->meta->make_immutable;
1;


