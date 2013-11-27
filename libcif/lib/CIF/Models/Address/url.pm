package CIF::Models::Address::url;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'url' }

__PACKAGE__->meta->make_immutable;
1;



