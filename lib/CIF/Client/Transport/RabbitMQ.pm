package CIF::Client::Transport::RabbitMQ;

use strict;
use warnings;
use Mouse;
use CIF::Client::Transport;
use CIF::Common::RabbitMQRole;
with 'CIF::Client::Transport';
with 'CIF::Common::RabbitMQRole';
use namespace::autoclean;

use CIF qw/debug/;

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

sub _query {
    my $self = shift;
    my $query = shift;
    my $body = $self->encode_query($query);

    my $result = $self->channel->declare_queue( 
      queue => "",
      durable => 0,
      exclusive => 1
    );
    my $queue_name =  $result->method_frame->queue;

    my $cv = AnyEvent->condvar;

    my $timer = AnyEvent->timer(after => 5, cb => sub {$cv->send(undef);});

    $self->channel->consume(
        no_ack => 1, 
        on_consume => sub {
          my $resp = shift;
          $cv->send($resp);
        }
    );

    $self->channel->publish(
      exchange => $self->query_exchange,
      routing_key => $self->query_key,
      body => $body,
      header => {
        reply_to => $queue_name
      }
    );

    my $response = $cv->recv;
    undef($timer);
    if (defined($response)) {
      my $content_type = $response->{header}->{content_type};
      my $message_type = $response->{header}->{type};
      if ($message_type eq 'query_response') {
        return $self->decode_query_results($content_type, $response->{body}->{payload});
      } else {
        die($response->{body}->{payload});
      }
    } else {
      die("Timed out while waiting for reply.");
    }
}

sub _ping {
    my $self = shift;
    my $hostinfo = shift;
    my $body = $self->encode_hostinfo($hostinfo);

    my $result = $self->channel->declare_queue( 
      queue => "",
      durable => 0,
      exclusive => 1
    );
    my $queue_name =  $result->method_frame->queue;

    my $cv = AnyEvent->condvar;

    my @responses;

    my $timer = AnyEvent->timer(after => 5, cb => sub {$cv->send(undef);});

    $self->channel->consume(
        no_ack => 1, 
        on_consume => sub {
          my $resp = shift;
          push(@responses, $resp);
        }
    );

    $self->channel->publish(
      exchange => $self->control_exchange,
      routing_key => $self->control_key,
      body => $body,
      header => {
        reply_to => $queue_name
      }
    );

    $cv->recv();

    my @ret;

    foreach my $response (@responses) {
      my $content_type = $response->{header}->{content_type};
      my $message_type = $response->{header}->{type};
      if ($message_type eq 'pong') {
        my $v = $self->decode_hostinfo($content_type, $response->{body}->{payload});
        push(@ret, $v);
      } else {
        debug("Bad response: " . $response->{body}->{payload});
      }
    }

    return \@ret;
}

sub _submit {
    my $self = shift;
    my $submission = shift;

    my $body = $self->encode_submission($submission);
    $self->channel->publish(
      exchange => $self->submit_exchange,
      routing_key => $self->submit_key,
      body => $body 
    );
    return undef;
}
__PACKAGE__->meta->make_immutable();
1;



