package Cikl::Util::Flusher;

use strict;
use warnings;
use AnyEvent;
use Coro;
use Mouse;
use namespace::autoclean;
use Cikl::Util::Flushable;
use Cikl qw/debug/;
use Time::HiRes qw/time/;

has 'flushable' => (
  is => 'ro',
  does => 'Cikl::Util::Flushable',
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

has '_next_flush' => (
  is => 'rw',
  init_arg => undef,
  default => undef
);

sub flush {
  my $self = shift;
  $self->_next_flush(undef);
  return if ($self->num_inserts == 0);
  my $num_inserts = $self->num_inserts;
  $self->num_inserts(0);

  my $ret = $self->flushable->flush($num_inserts);

  foreach my $cb (@{$self->flush_callbacks()}) {
    $cb->($ret);
  }

  return $ret;
}

sub checkpoint {
  my $self = shift;
  if ($self->num_inserts >= $self->commit_size) {
    $self->flush();
  } elsif (defined($self->_next_flush()) && time() >= $self->_next_flush()) {
    $self->flush();
  }
}

sub tick {
  my $self = shift;
  my $event = shift;
  $self->num_inserts($self->num_inserts + 1);

  if (!defined($self->_next_flush())) {
    $self->_next_flush(time() + $self->commit_interval);
  }

  $self->checkpoint();
}

__PACKAGE__->meta->make_immutable;
1;

