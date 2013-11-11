package CIF::Client::Transport::RabbitMQ;
use base 'CIF::Client::Transport';

use strict;
use warnings;
use JSON qw{encode_json};

use Net::RabbitFoot;
use CIF qw/debug/;

sub new {
    my $class = shift;
    my $args = shift;
    $args->{driver_name} = "rabbitmq";

    my $self = $class->SUPER::new($args);
    my $config = $self->get_config();

    my $amqp = Net::RabbitFoot->new()->load_xml_spec()->connect(
      host => $self->config("host") || "localhost",
      port => $self->config("port") || 5672,
      user => $self->config("username") || "guest",
      pass => $self->config("password") || "guest",
      vhost => $self->config("vhost") || "/",
    );
    my $channel = $amqp->open_channel();

    $self->{exchange_name} = "cif";
    $self->{fanout_exchange_name} = $self->{exchange_name} . "_fanout";
    $self->{submit_key} = "submit";
    $self->{query_key} = "query";
    $self->{ping_key} = "ping";
    $self->{amqp} = $amqp;
    $self->{channel} = $channel;

    return $self;
}

sub shutdown {
    my $self = shift;
    if (!$self->SUPER::shutdown()) {
      # We've already shutdown.
      return 0;
    }

    if ($self->{channel}) {
      $self->{channel}->close();
      $self->{channel} = undef;
    }

    if ($self->{amqp}) {
      $self->{amqp}->close();
      $self->{amqp} = undef;
    }

    return 1;
}

sub query {
    my $self = shift;
    my $query = shift;
    my $body = $self->encode_query($query);

    my $result = $self->{channel}->declare_queue( 
      queue => "",
      durable => 0,
      exclusive => 1
    );
    my $queue_name =  $result->method_frame->queue;

    my $cv = AnyEvent->condvar;

    my $timer = AnyEvent->timer(after => 5, cb => sub {$cv->send(undef);});

    $self->{channel}->consume(
        no_ack => 1, 
        on_consume => sub {
          my $resp = shift;
          $cv->send($resp);
        }
    );

    $self->{channel}->publish(
      exchange => $self->{exchange_name},
      routing_key => $self->{query_key},
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

sub ping {
    my $self = shift;
    my $hostinfo = shift;
    my $body = $self->encode_hostinfo($hostinfo);

    my $result = $self->{channel}->declare_queue( 
      queue => "",
      durable => 0,
      exclusive => 1
    );
    my $queue_name =  $result->method_frame->queue;

    my $cv = AnyEvent->condvar;

    my @responses;

    my $timer = AnyEvent->timer(after => 5, cb => sub {$cv->send(undef);});

    $self->{channel}->consume(
        no_ack => 1, 
        on_consume => sub {
          my $resp = shift;
          push(@responses, $resp);
        }
    );

    $self->{channel}->publish(
      exchange => $self->{fanout_exchange_name},
      routing_key => $self->{ping_key},
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

sub submit {
    my $self = shift;
    my $submission = shift;

    my $body = $self->encode_submission($submission);
    $self->{channel}->publish(
      exchange => $self->{exchange_name},
      routing_key => $self->{submit_key},
      body => $body 
    );
    return undef;
}
1;



