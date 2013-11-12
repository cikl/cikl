package CIF::Router::Transport::RabbitMQ;
use base 'CIF::Router::Transport';

use strict;
use warnings;

use Net::RabbitFoot;
use Coro;
use Try::Tiny;
use CIF qw/debug/;
use CIF::Router::Constants;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{exchange_name} = $self->config("exchange") || "cif";
    $self->{fanout_exchange_name} = $self->{exchange_name} . "_fanout";

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
      queue_name => '',
      routing_key => ($self->config("ping_key") || "ping"),
      exchange_name => $self->{fanout_exchange_name},
      exchange_type => 'fanout',
      durable => 0,
      auto_delete => 1
    };

    $self->{submission_config} = $submission_config;
    $self->{query_config} = $query_config;
    $self->{ping_config} = $ping_config;

    $self->{amqp} = Net::RabbitFoot->new()->load_xml_spec()->connect(%$rabbitmq_opts);
    $self->{channels} = [];

    $self->_init_service($self->service());
    return($self);
}

sub _init_channel {
    my $self = shift;
    my $channel = $self->{amqp}->open_channel();
    my $config = shift;
    my $service = shift;
    my $service_method = shift;

    $channel->qos(prefetch_count => ($self->config("prefetch_count") || 1));

    $channel->declare_exchange(
      exchange => $config->{exchange_name} || $self->{exchange_name},
      type => $config->{exchange_type} || 'topic',
      durable => 1
    );

    $self->_init_queue($channel, $config);
    $self->_init_consume($channel, $service, $service_method);

    return $channel;
}

sub _init_consume {
    my $self = shift;
    my $channel = shift;
    my $service = shift;
    my $service_method = shift;
    $channel->consume(
      no_ack => 0,
      on_consume => sub {
        my $msg = shift;
        $self->_handle_msg($channel, $msg, $service, $service_method);
      }
    );
}

sub _handle_msg {
    my $self = shift;
    my $channel = shift;
    my $msg = shift;
    my $service = shift;
    my $service_method = shift;

    my $payload = $msg->{body}->payload;
    $channel->ack(delivery_tag => 
      $msg->{deliver}->method_frame->delivery_tag
    );

    my ($reply, $type, $content_type) = $service->$service_method($payload);

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
      exchange => $config->{exchange_name} || $self->{exchange_name},
      queue => $config->{queue_name},
      routing_key => $config->{routing_key}
    );
}

sub _setup_processor {
    my $self = shift;
    my $config = shift;
    my $service = shift;
    my $channel = $self->_init_channel($config, $service, "process");
    push(@{$self->{channels}}, $channel); 

    my $ping_channel = $self->_init_channel($self->{ping_config}, $service, "process_hostinfo_request");
    push(@{$self->{channels}}, $ping_channel); 
    return undef;
}

sub setup_ping_processor {
    my $self = shift;
    my $payload_callback = shift;
    $self->_setup_processor($self->{ping_config}, $payload_callback);
}

sub _init_service {
    my $self = shift;
    my $service = shift;
    if ($service->service_type() == SVC_SUBMISSION) {
      $self->setup_submission_processor($service);
    } elsif ($service->service_type() == SVC_QUERY) {
      $self->setup_query_processor($service);
    } else {
      die("Unknown service type: " . $service->name());
    }
}

sub setup_query_processor {
    my $self = shift;
    my $service = shift;
    $self->_setup_processor($self->{query_config}, $service);
}

sub setup_submission_processor {
    my $self = shift;
    my $service = shift;
    $self->_setup_processor($self->{submission_config}, $service);
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


