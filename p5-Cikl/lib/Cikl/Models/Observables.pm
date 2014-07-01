package Cikl::Models::Observables;
use strict;
use warnings;
use Mouse;
use Cikl::Models::Observable;
use namespace::autoclean;

use constant TYPES => qw/asn email fqdn ipv4 ipv4_cidr url/;

foreach my $type (TYPES) {
  has $type => (
    is => 'ro',
    isa => 'ArrayRef[Cikl::Models::Observable::' . $type . ']',
    default => sub { [] } 
  );
}

sub add {
  my $self = shift;
  my $address = shift;

  my $method = $address->type();
  push($self->$method(), $address);
}

sub count {
  my $self = shift;
  my $count = 0;
  foreach my $type (TYPES) {
    $count = $count + (@{$self->$type});
  }
  return $count;
}

sub is_empty {
  my $self = shift;
  return $self->count() == 0;
}

sub to_hash {
  my $self = shift;
  my $ret = { };
  # Go through and delete any empty arrays!
  foreach my $type (TYPES) {
    my $data = $self->$type;
    if (@{$data}) {
      my $results = [];
      foreach my $obj (@{$data}) {
        push(@$results, $obj->to_hash());
      }
      $ret->{$type} = $results;
    }
  }
  return $ret;
}

__PACKAGE__->meta->make_immutable;

1;

