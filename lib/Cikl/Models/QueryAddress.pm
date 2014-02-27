package Cikl::Models::QueryAddress;
use strict;
use warnings;
use Mouse;
use Mouse::Util::TypeConstraints;
use namespace::autoclean;

enum 'QueryOperator' => qw(
 asn
 email
 fqdn
 ip
 url
 assessment
);

no Mouse::Util::TypeConstraints;

has 'operator' => (
  is => 'rw',
  isa => 'QueryOperator',
  required => 1
);

has 'value' => (
  is => 'rw',
  isa => 'Str',
  required => 1
);

sub to_hash {
  my $self = shift;
  return { %$self };
}

sub from_hash {
  my $class = shift;
  return $class->new(@_)
}

__PACKAGE__->meta->make_immutable();

1;



