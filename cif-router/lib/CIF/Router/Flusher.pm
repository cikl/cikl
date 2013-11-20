package CIF::Router::Flusher;

use strict;
use warnings;
use AnyEvent;
use Coro;
use Moose;
use namespace::autoclean;

has 'commit_callback' => (
  is => 'ro',
  isa => 'CodeRef',
  required => 1
);

has 'commit_interval' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);

has 'commit_size' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);

has 'num_inserts' => (
  is => 'rw',
  isa => 'Num',
  init_arg => undef,
  default => 0
);

sub flush {
  my $self = shift;
  return if ($self->num_inserts == 0);
  my $num_inserts = $self->num_inserts;
  $self->num_inserts(0);
  $self->commit_callback->($num_inserts);
}

sub tick {
  my $self = shift;
  my $event = shift;
  $self->num_inserts($self->num_inserts + 1);

  if ($self->num_inserts >= $self->commit_size) {
    $self->flush();
  } else {
    $self->defer_flush();
  }
}

sub defer_flush {
  my $self = shift;
  die("defer_flush not implemented!");
}

__PACKAGE__->meta->make_immutable;
1;

