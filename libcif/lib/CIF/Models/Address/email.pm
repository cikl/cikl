package CIF::Models::Address::email;
use strict;
use warnings;
use Mouse;
use CIF::Models::AddressRole;
use namespace::autoclean;
use CIF::DataTypes;
with 'CIF::Models::AddressRole';

sub type { 'email' }

has '+value' => (
  isa => 'CIF::DataTypes::Email',
);

sub normalize_value {
  my $class = shift;
  my $value = shift;
  return $value unless ($value && ref($value) eq '');
  $value =~ s/^\s+//;
  $value =~ s/\s+$//;
  return lc($value);
}

__PACKAGE__->meta->make_immutable;
1;
