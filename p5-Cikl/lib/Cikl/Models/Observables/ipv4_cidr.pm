package Cikl::Models::Observables::ipv4_cidr;
use strict;
use warnings;
use Mouse;
use Cikl::Models::Observable;
use Cikl::DataTypes::Ipv4Cidr;
use namespace::autoclean;
with 'Cikl::Models::Observable';

sub type { 'ipv4_cidr' }

has '+value' => (
  isa => 'Cikl::DataTypes::Ipv4Cidr'
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


