package CIF::Models::Address::ipv4;
use strict;
use warnings;
use Moose;
use CIF::Models::AddressRole;
use CIF::MooseTypes;
use namespace::autoclean;
with 'CIF::Models::AddressRole';

sub type { 'ipv4' }

has '+value' => (
  isa => 'CIF::MooseTypes::Ipv4'
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

