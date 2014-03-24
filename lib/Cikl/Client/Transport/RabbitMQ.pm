package Cikl::Client::Transport::RabbitMQ;

use strict;
use warnings;
use Mouse;
use Cikl::Client::Transport;
use Cikl::Common::RabbitMQRole;
with 'Cikl::Client::Transport';
with 'Cikl::Common::RabbitMQRole';
use namespace::autoclean;

use Cikl qw/debug/;

has 'channel' => (
  is => 'ro', 
  init_arg => undef,
  lazy_build => 1
);

sub _build_channel {
  my $self = shift;
  return $self->amqp()->open_channel();
}

after 'shutdown' => sub {
    my $self = shift;

    if ($self->has_channel()) {
      $self->channel->close();
      $self->clear_channel();
    }

    $self->shutdown_amqp();

    return 1;
};

sub _submit {
    my $self = shift;
    my $event = shift;

    my $body = $self->encode_event($event);
    $self->channel->publish(
      exchange => $self->submit_exchange,
      routing_key => $self->submit_key,
      body => $body 
    );
    return undef;
}
__PACKAGE__->meta->make_immutable();
1;



