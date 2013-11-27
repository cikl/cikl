package CIF::Models::Address::asn;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'asn' }

__PACKAGE__->meta->make_immutable;
1;


