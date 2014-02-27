package Cikl::Router::Transport::RabbitMQ::Consumer;
use strict;
use warnings;

require Cikl::Router::Transport::RabbitMQ::DeferredAcker;
use Cikl qw/debug/;
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

has 'on_success_callback' => (
  is => 'rw',
  isa => 'CodeRef',
  lazy_build => 1
);

has 'on_failure_callback' => (
  is => 'rw',
  isa => 'CodeRef',
  lazy_build => 1
);

has 'consumer_tag' => (
  is => 'rw',
  init_arg => undef,
  clearer => "clear_consumer_tag",
  predicate => "has_consumer_tag"
);

sub handle_success {
  my $self = shift;
  my $args = shift;
  my $m = $args->{callback_data};
  $self->acker->ack($m->{deliver}->method_frame->delivery_tag);
  my $reply_queue = $m->{header}->{reply_to};
  if (defined($reply_queue)) {
    $self->_send_reply(
      $reply_queue, 
      $m->{header}->{correlation_id}, 
      $args->{encoded_work_results},
      $args->{response_type},
      $args->{content_type}
    );
  }
}

sub _build_on_success_callback {
  my $self = shift;
  my $ret = sub {
    $self->handle_success(@_);
  };
  return $ret;
}

use constant FAILURE_MESSAGE_TYPE => 'error';
use constant FAILURE_CONTENT_TYPE => 'text/plain';
use constant FAILURE_MESSAGE_FORMAT => "Error while processing message: %s";

sub handle_failure {
  my $self = shift;
  my $args = shift;
  print Dumper $args;
  my $m = $args->{callback_data};
  my $err = $args->{error};
  $self->acker->reject($m->{deliver}->method_frame->delivery_tag);
  my $reply_queue = $m->{header}->{reply_to};
  if (defined($reply_queue)) {
    $self->_send_reply(
      $reply_queue, 
      $m->{header}->{correlation_id},
      sprintf(FAILURE_MESSAGE_FORMAT, $err),
      FAILURE_MESSAGE_TYPE, 
      FAILURE_CONTENT_TYPE);
  }
}

sub _build_on_failure_callback {
  my $self = shift;
  my $ret = sub {
    $self->handle_failure(@_);
  };
  return $ret;
}

sub _build_acker {
  my $self = shift;
  my $acker = Cikl::Router::Transport::RabbitMQ::DeferredAcker->new(
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

  $self->clear_on_success_callback();
  $self->clear_on_failure_callback();
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

sub _send_reply {
  my $self = shift;
  my $reply_queue = shift;
  my $correlation_id = shift;
  my $reply = shift;
  my $type = shift;
  my $content_type = shift;

  $self->channel->publish(
    # Note that we don't specify an exchange when replying.
    exchange => '',
    routing_key => $reply_queue,
    body => $reply,
    header => {
      content_type => $content_type,
      correlation_id => $correlation_id,
      type => $type 
    }
  );
}

sub _handle_msg {
  my $self = shift;
  my $msg = shift;

  $self->service->process({
      payload => $msg->{body}->payload,
      callback_data => $msg,
      on_success => $self->on_success_callback(),
      on_failure => $self->on_failure_callback()
    });
}

__PACKAGE__->meta->make_immutable();
1;
