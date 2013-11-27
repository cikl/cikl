package CIF::Models::Address::ipv4_cidr;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'ipv4_cidr' }

__PACKAGE__->meta->make_immutable;
1;


