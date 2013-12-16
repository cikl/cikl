package CIF::DataStore::Flusher;

use strict;
use warnings;
use AnyEvent;
use Coro;
use Mouse;
use namespace::autoclean;
use CIF::DataStore::Role;
use CIF qw/debug/;

has 'datastore' => (
  is => 'ro',
  isa => 'CIF::DataStore::Role',
  required => 1
);

has 'flush_callbacks' => (
  is => 'ro',
  isa => 'ArrayRef[CodeRef]',
  init_arg => undef,
  default => sub {[]},
  traits => ['Array'],
  handles => {
    add_flush_callback => 'push'
  }
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

  my $submissions = $self->datastore->flush($num_inserts);

  foreach my $cb (@{$self->flush_callbacks()}) {
    $cb->($submissions);
  }

  return $submissions;
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

