package Cikl::Models::Observables::asn;
use strict;
use warnings;
use Mouse;
use Cikl::Models::Observable;
use Cikl::DataTypes::Asn;
use namespace::autoclean;
with 'Cikl::Models::Observable';

sub type { 'asn' }

has '+value' => (
  isa => 'Cikl::DataTypes::Asn',
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


