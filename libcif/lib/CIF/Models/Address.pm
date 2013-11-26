package CIF::Models::Address;
use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

has 'value' => (
  isa => 'Str',
  is => "ro",
  required => 1
);

has 'type' => (
  is => "ro",
  required => 1,
  ## From https://github.com/csirtgadgets/sligo-protocol#address-class
  #isa => enum([qw[asn ipv4 ipv6 fqdn url email mac]])
  isa => enum([qw[asn ipv4 fqdn url email]])
);

sub to_hash {
  my $self = shift;
  my $data = {};
  foreach my $key (keys %$self) {
    $data->{$key} = $self->{$key};
  }
  return $data;
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  return $class->new($data);
}

__PACKAGE__->meta->make_immutable;

1;
