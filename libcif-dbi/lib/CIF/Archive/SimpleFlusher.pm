package CIF::Archive::SimpleFlusher;

use strict;
use warnings;
use AnyEvent;
use Coro;
use Moose;
use CIF::Archive::Flusher;
extends 'CIF::Archive::Flusher';
use namespace::autoclean;

has '_next_flush' => (
  is => 'rw',
  init_arg => undef,
  default => undef
);

sub flush {
  my $self = shift;
  $self->_next_flush(undef);
  return $self->SUPER::flush();
}

sub defer_flush {
  my $self = shift;
  if (!defined($self->_next_flush())) {
    $self->_next_flush(time() + $self->commit_interval);
  } elsif (time() >= $self->_next_flush) {
    $self->flush();
  }
}

__PACKAGE__->meta->make_immutable;
1;

