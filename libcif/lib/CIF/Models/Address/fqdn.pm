package CIF::Models::Address::fqdn;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'fqdn' }

__PACKAGE__->meta->make_immutable;
1;
