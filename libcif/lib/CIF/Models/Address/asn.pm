package CIF::Models::Address::asn;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use CIF::DataTypes;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'asn' }

has '+value' => (
  isa => 'CIF::DataTypes::Asn',
);

sub normalize_value {
  my $class = shift;
  my $value = shift;
  return $value unless ($value && ref($value) eq '');
  $value =~ s/^\s+//;
  $value =~ s/\s+$//;
  return $value;
}

__PACKAGE__->meta->make_immutable;
1;


