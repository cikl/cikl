package Cikl::Router::Transport::RabbitMQ;

use strict;
use warnings;

use Cikl::Router::Transport;
use Mouse;
use AnyEvent;
use Coro;
use Try::Tiny;
use Cikl qw/debug/;
use Cikl::Router::Constants;
use Cikl::Common::RabbitMQRole;
use Cikl::Router::Transport::RabbitMQ::Consumer;
use Cikl::Router::Transport::RabbitMQ::SubmissionConsumer;
use namespace::autoclean;

with 'Cikl::Router::Transport';
with 'Cikl::Common::RabbitMQRole';

has 'prefetch_count' => (
  is => 'ro',
  isa => 'Num',
  builder => sub { $_[0]->{prefetch_count} || 500 }
);

has 'query_queue' => (
  is => 'ro',
  isa => 'Str',
  default => 'query-queue'
);

has 'submit_queue' => (
  is => 'ro',
  isa => 'Str',
  default => 'submit-queue'
);

has 'query_prefetch' => (
  is => 'ro',
  default => 2
);

has 'submit_prefetch' => (
  is => 'ro',
  default => 500
);

has 'channels' => (
  is => 'ro',
  isa => 'ArrayRef',
  lazy_build => 1,
  traits => [ 'Array' ],
  init_arg => undef,
);

sub _build_channels {
  return [];
}

has 'consumers' => (
  is => 'ro',
  isa => 'ArrayRef',
  lazy_build => 1,
  traits => [ 'Array' ],
  init_arg => undef,
);

sub _build_consumers {
  return [];
}

sub register_service {
  my $self = shift;
  my $service = shift;
  my $service_type = $service->service_type();

  my %config;
  my $consumer = undef;
  my $channel = $self->amqp->open_channel();
  push(@{$self->channels()}, $channel); 
  $config{channel} = $channel;
  $config{service} = $service;

  if ($service_type == Cikl::Router::Constants::SVC_SUBMISSION) {
    %config = (%config, %{$self->_submission_service_config()});
    $config{postprocess_exchange} = $self->postprocess_exchange;
    $config{postprocess_key} = $self->postprocess_key;
    $consumer = Cikl::Router::Transport::RabbitMQ::SubmissionConsumer->new(\%config);
  } elsif ($service_type == Cikl::Router::Constants::SVC_QUERY) {
    %config = (%config, %{$self->_query_service_config()});
    $consumer = Cikl::Router::Transport::RabbitMQ::Consumer->new(\%config);
  } elsif ($service_type == Cikl::Router::Constants::SVC_CONTROL) {
    %config = (%config, %{$self->_control_service_config()});
    $consumer = Cikl::Router::Transport::RabbitMQ::Consumer->new(\%config);
  } else {
    die "Unknown service type: $service_type";
  }

  push(@{$self->consumers()}, $consumer); 

  $consumer->start();
}

sub _query_service_config {
  my $self = shift;
  return {
    exchange_name => $self->query_exchange,
    exchange_type => "topic",
    queue_name => $self->query_queue,
    routing_key =>  $self->query_key,
    prefetch => $self->query_prefetch,
    durable => 0,
    auto_delete => 1
  };
}

sub _submission_service_config {
  my $self = shift;
  return {
    exchange_name => $self->submit_exchange,
    exchange_type => "topic",
    queue_name => $self->submit_queue,
    routing_key =>  $self->submit_key,
    prefetch => $self->submit_prefetch,
    durable => 1,
    auto_delete => 0
  };
}

sub _control_service_config {
  my $self = shift;
  return {
    exchange_name => $self->control_exchange,
    exchange_type => "fanout",
    queue_name => "",
    routing_key =>  $self->control_key,
    prefetch => 1,
    durable => 0,
    auto_delete => 1
  };
}

sub start {
  my $self = shift;
  if (($#{$self->channels} == -1)) {
    die "Nothing to start! No services have been registered!";
  }
}

sub stop {
  my $self = shift;
  if (!$self->has_amqp()) {
    return;
  }

  foreach my $consumer (@{$self->consumers}) {
    $consumer->stop();
  }
  # Clear the stopped consumers;
  $self->clear_consumers();

  foreach my $channel (@{$self->channels}) {
    $channel->close();
  }
  # Clear the closed channels;
  $self->clear_channels();
  $self->amqp->close();
  $self->clear_amqp();
}

# This gets called before shutdown.
sub shutdown {
  my $self = shift;

}

__PACKAGE__->meta->make_immutable();

1;
