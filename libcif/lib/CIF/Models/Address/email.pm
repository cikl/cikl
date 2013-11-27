package CIF::Models::Address::email;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'email' }

__PACKAGE__->meta->make_immutable;
1;




