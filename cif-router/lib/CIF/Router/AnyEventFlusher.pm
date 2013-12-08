package CIF::Router::AnyEventFlusher;

use strict;
use warnings;
use AnyEvent;
use Coro;
use Mouse;
use CIF::Archive::Flusher;
extends 'CIF::Archive::Flusher';
use namespace::autoclean;

has '_flush_timer' => (
  is => 'rw',
  init_arg => undef,
  default => undef

);

sub flush {
  my $self = shift;
  $self->_flush_timer(undef);
  return $self->SUPER::flush();
}

sub defer_flush {
  my $self = shift;
  return if (defined($self->_flush_timer));
  my $cb = sub { $self->flush();};
  $self->_flush_timer(AnyEvent->timer(after => $self->commit_interval, cb => $cb));
}

__PACKAGE__->meta->make_immutable;
1;
