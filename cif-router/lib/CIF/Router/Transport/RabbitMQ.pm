package CIF::Router::Transport::RabbitMQ;
use base 'CIF::Router::Transport';

use strict;
use warnings;

use Net::RabbitFoot;
use Coro;
use Try::Tiny;
use CIF qw/debug/;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{exchange_name} = $self->config("exchange") || "cif";

    my $rabbitmq_opts = {
      host => $self->config("host") || "localhost",
      port => $self->config("port") || 5672,
      user => $self->config("username") || "guest",
      pass => $self->config("password") || "guest",
      vhost => $self->config("vhost") || "/",
    };

    my $submission_config = {
      queue_name => ($self->config("submission_queue") || "cif-submit-queue"),
      routing_key => ($self->config("submission_key") || "submit"),
      durable => 1,
      auto_delete => 0
    };

    my $query_config = {
      queue_name => ($self->config("query_queue") || "cif-query-queue"),
      routing_key => ($self->config("query_key") || "query"),
      durable => 0,
      auto_delete => 1
    };

    my $ping_config = {
      queue_name => ($self->config("ping_queue") || "cif-ping-queue"),
      routing_key => ($self->config("ping_key") || "ping"),
      durable => 0,
      auto_delete => 1
    };

    $self->{submission_config} = $submission_config;
    $self->{query_config} = $query_config;
    $self->{ping_config} = $ping_config;

    $self->{amqp} = Net::RabbitFoot->new()->load_xml_spec()->connect(%$rabbitmq_opts);
    $self->{channels} = [];
    return($self);
}

sub _init_channel {
    my $self = shift;
    my $channel = $self->{amqp}->open_channel();
    my $config = shift;
    my $payload_callback = shift;

    $channel->qos(prefetch_count => ($self->config("prefetch_count") || 1));

    $channel->declare_exchange(
      exchange => $self->{exchange_name},
      type => 'topic',
      durable => 1
    );

    $self->_init_queue($channel, $config);
    $self->_init_consume($channel, $payload_callback);

    return $channel;
}

sub _init_consume {
    my $self = shift;
    my $channel = shift;
    my $payload_callback = shift;
    $channel->consume(
      no_ack => 0,
      on_consume => sub {
        my $msg = shift;
        $self->_handle_msg($channel, $msg, $payload_callback);
      }
    );
}

sub _handle_msg {
    my $self = shift;
    my $channel = shift;
    my $msg = shift;
    my $payload_callback = shift;

    my $payload = $msg->{body}->payload;
    $channel->ack(delivery_tag => 
      $msg->{deliver}->method_frame->delivery_tag
    );

    my ($reply, $type, $content_type) = $payload_callback->($payload);

    if (my $reply_queue = $msg->{header}->{reply_to}) {
      $channel->publish(
        # Note that we don't specify an exchange when replying.
        exchange => '',
        routing_key => $reply_queue,
        body => $reply,
        header => {
          content_type => $content_type,
          type => $type 
        }
      );
    }
}

sub _init_queue {
    my $self = shift;
    my $channel = shift;
    my $config = shift;

    my $result = $channel->declare_queue(
      queue => $config->{queue_name},
      durable => $config->{durable},
      auto_delete => $config->{auto_delete}
    );

    $channel->bind_queue(
      exchange => $self->{exchange_name},
      queue => $config->{queue_name},
      routing_key => $config->{routing_key}
    );
}

sub _setup_processor {
    my $self = shift;
    my $config = shift;
    my $payload_callback = shift;
    my $channel = $self->_init_channel($config, $payload_callback);
    push(@{$self->{channels}}, $channel); 
    return undef;
}

sub setup_ping_processor {
    my $self = shift;
    my $payload_callback = shift;
    $self->_setup_processor($self->{ping_config}, $payload_callback);
}

sub setup_query_processor {
    my $self = shift;
    my $payload_callback = shift;
    $self->_setup_processor($self->{query_config}, $payload_callback);
}

sub setup_submission_processor {
    my $self = shift;
    my $payload_callback = shift;
    $self->_setup_processor($self->{submission_config}, $payload_callback);
}

sub start {
    my $self = shift;
    if (!defined($self->{amqp})) {
      die "The connection has already been shutdown!";
    }
    if (($#{$self->{channels}} == -1)) {
      die "Nothing to start! No services have been created!";
    }
}

sub stop {
    my $self = shift;
}

# This gets called before shutdown.
sub shutdown {
    my $self = shift;

    if (!defined($self->{amqp})) {
      return;
    }
    debug("Shutting down");

    foreach my $channel (@{$self->{channels}}) {
      $channel->close();
    }
    # Clear the closed channels;
    $#{$self->{channels}} = -1;

    $self->{amqp}->close();
    $self->{amqp} = undef;
}

1;


