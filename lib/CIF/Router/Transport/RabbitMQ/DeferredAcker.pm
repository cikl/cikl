package CIF::Router::Transport::RabbitMQ::DeferredAcker;
use strict;
use warnings;

use Mouse;
use namespace::autoclean;

has 'channel' => (
  is => 'ro',
  #isa => ???,
  required => 1
);

has 'max_outstanding' => (
  is => 'ro',
  isa => 'Int',
  required => 1
);

has 'timeout' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);

has '_counter' => (
  traits  => ['Counter'],
  is => 'rw',
  isa => 'Int',
  init_arg => undef,
  default => 0,
  handles => {
    inc_counter   => 'inc',
    reset_counter => 'reset',
  }
);

has '_last_tag' => (
  is => 'rw',
  init_arg => undef
);

has '_timer' => (
  is => 'rw',
  init_arg => undef

);

sub ack {
  my $self = shift;
  $self->_last_tag(shift);
  $self->inc_counter();
  if ($self->_counter >= $self->max_outstanding()) {
    # Flush after X messages.
    $self->flush();
  } elsif (!defined($self->_timer)) {
    # Create timer that will flush for us.
    $self->_timer(AnyEvent->timer(
        after => $self->timeout, 
        cb => sub {$self->flush();}
      ));
  }
};

sub reject {
  my $self = shift;
  my $tag = shift;
  $self->flush();
  $self->channel->reject(delivery_tag => $tag);
}

sub flush {
  my $self = shift;
  $self->_timer(undef);
  $self->reset_counter();
  my $last_tag = $self->_last_tag;
  return if (!defined($last_tag));
  $self->channel->ack(delivery_tag => $last_tag, multiple => 1);
  $self->_last_tag(undef);
}

__PACKAGE__->meta->make_immutable();

1;

