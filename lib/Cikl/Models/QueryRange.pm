package Cikl::Models::QueryRange;
use strict;
use warnings;
use Mouse;
use namespace::autoclean;

# If this is undef, it will be treated as -infinity
has 'min' => (
  is => 'rw',
  isa => 'Maybe[Num]',
  required => 0
);

# If this is undef, it will be treated as +infinity
has 'max' => (
  is => 'rw',
  isa => 'Maybe[Num]',
  required => 0
);

sub BUILD {
  my $self = shift;
  my $min = $self->min();
  my $max = $self->max();
  if (defined($min) && defined($max) && $min > $max) {
    die("min ($min) cannot be greater than max ($max)");
  }
}

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




