package CIF::Router::Transport::RabbitMQ::Consumer;
use strict;
use warnings;

require CIF::Router::Transport::RabbitMQ::DeferredAcker;
use CIF qw/debug/;
use AnyEvent;
use Try::Tiny;
use Mouse;
use namespace::autoclean;

has 'service' => (
  is => 'ro',
  required => 1
);
has 'channel' => (
  is => 'ro',
  required => 1
);

has 'exchange_name' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);
has 'exchange_type' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);
has 'queue_name' => (
  is => 'ro',
  isa => 'Str',
  required => 0
);
has 'routing_key' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);
has 'prefetch' => (
  is => 'ro',
  isa => 'Num',
  default => 1
);
has 'durable' => (
  is => 'ro',
  isa => 'Bool',
  default => 0
);
has 'auto_delete' => (
  is => 'ro',
  isa => 'Bool',
  default => 1
);

has 'acker' => (
  is => 'rw',
  init_arg => undef,
  lazy_build => 1
);

has 'consumer_tag' => (
  is => 'rw',
  init_arg => undef,
  clearer => "clear_consumer_tag",
  predicate => "has_consumer_tag"
);

sub _build_acker {
  my $self = shift;
  my $acker = CIF::Router::Transport::RabbitMQ::DeferredAcker->new(
    channel => $self->channel,
    max_outstanding => $self->prefetch,
    timeout => 1
  );
  return $acker;
}

sub BUILD {
  my $self = shift;

  $self->channel->declare_exchange(
    exchange => $self->exchange_name,
    type => $self->exchange_type,
    durable => 1,
    auto_delete => 0
  );
  $self->channel->qos(prefetch_count => $self->prefetch);

  my $result = $self->channel->declare_queue(
    queue => $self->queue_name,
    durable => $self->durable,
    auto_delete => $self->auto_delete
  );

  $self->channel->bind_queue(
    exchange => $self->exchange_name,
    queue => $self->queue_name,
    routing_key => $self->routing_key
  );
}

sub start {
  my $self = shift;
  $self->_init_consume();
}

sub stop {
  my $self = shift;
  if ($self->has_consumer_tag) {
    $self->channel->cancel(
      consumer_tag => $self->consumer_tag()
    );
  }
  if ($self->has_acker()) {
    $self->acker->flush();
    $self->clear_acker();
  }
}

sub _init_consume {
  my $self = shift;
  my $ret = $self->channel->consume(
    no_ack => 0,
    on_consume => sub {
      $self->_handle_msg($_[0]);
    }
  );
  $self->consumer_tag($ret->method_frame->consumer_tag);

}

sub _handle_msg {
  my $self = shift;
  my $msg = shift;

  my $payload = $msg->{body}->payload;
  my ($reply, $type, $content_type, $err);

  try {
    ($reply, $type, $content_type) = $self->service->process($payload);
  } catch {
    $err = shift;
  };

  if ($err) {
    $reply = "Error while processing message: $err";
    $type = "error";
    $content_type = "text/plain";
    debug($reply);
    $self->acker->reject($msg->{deliver}->method_frame->delivery_tag);
  } else {
    $self->acker->ack($msg->{deliver}->method_frame->delivery_tag);
  }

  if (my $reply_queue = $msg->{header}->{reply_to}) {
    $self->channel->publish(
      # Note that we don't specify an exchange when replying.
      exchange => '',
      routing_key => $reply_queue,
      body => $reply,
      header => {
        content_type => $content_type,
        correlation_id => $msg->{header}->{correlation_id},
        type => $type 
      }
    );
  }
}

__PACKAGE__->meta->make_immutable();
1;
