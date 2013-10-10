package CIF::Router::Transport::RabbitMQ;
use base 'CIF::Router::Transport';

use strict;
use warnings;

use Data::Dumper;
use Net::RabbitFoot;
use Coro;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    my $exchange_name = $self->config("exchange") || "cif";

    if ($self->is_submission()) {
      $self->load_submission_config();
    } elsif ($self->is_query()) {
      $self->load_query_config();
    } else {
      die "Unknown type: ", $self->type();
    }

    my $rabbitmq_opts = {
      host => $self->config("host") || "localhost",
      port => $self->config("port") || 5672,
      user => $self->config("username") || "guest",
      pass => $self->config("password") || "guest",
      vhost => $self->config("vhost") || "/",
    };

    my $amqp = Net::RabbitFoot->new()->load_xml_spec()->connect(%$rabbitmq_opts);

    my $channel = $amqp->open_channel();

    $channel->qos(prefetch_count => $self->{prefetch_count});

    $channel->declare_exchange(
      exchange => $exchange_name,
      type => 'topic',
      durable => 1
    );

    my $result = $channel->declare_queue(
      queue => $self->{queue_name},
      durable => $self->{durable},
      auto_delete => $self->{auto_delete}
    );

    $channel->bind_queue(
      exchange => $exchange_name,
      queue => $self->{queue_name},
      routing_key => $self->{routing_key}
    );

    $self->{amqp} = $amqp;
    $self->{channel} = $channel;

    return($self);
}

sub load_query_config {
    my $self = shift;
    $self->{queue_name} = $self->config("query_queue") || "cif-query-queue";
    $self->{routing_key} = $self->config("query_key") || "query";
    $self->{prefetch_count} = $self->config("query_prefetch") || 1;
    $self->{durable} = 0;
    $self->{auto_delete} = 1;
}

sub load_submission_config {
    my $self = shift;
    $self->{queue_name} = $self->config("submission_queue") || "cif-submit-queue";
    $self->{routing_key} = $self->config("submission_key") || "submit";
    $self->{prefetch_count} = $self->config("submission_prefetch") || 10;
    $self->{durable} = 1;
    $self->{auto_delete} = 0;
}

sub run {
    my $self = shift;
    my $cv = AnyEvent->condvar;

    $self->{channel}->consume(
      on_consume => sub {
        my $msg = shift;
        my $payload = $msg->{body}->payload;
        my $reply = $self->process($payload);
        if (my $reply_queue = $msg->{header}->{reply_to}) {
          $self->{channel}->publish(
            exchange => $self->{exchange_name},
            routing_key => $reply_queue,
            body => $reply
          );
        }
      }
    );
    print "Ready\n";
    $cv->recv;
}

1;


