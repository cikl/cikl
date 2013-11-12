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

    $self->{exchange_name} = "amq.topic";
    $self->{fanout_exchange_name} = "amq.fanout";

    my $rabbitmq_opts = {
      host => $self->config("host") || "localhost",
      port => $self->config("port") || 5672,
      user => $self->config("username") || "guest",
      pass => $self->config("password") || "guest",
      vhost => $self->config("vhost") || "/cif",
    };
    
    my $service_name = $self->service->name();

    my $config = {
      queue_name => "$service_name-queue",
      routing_key =>  $service_name,
      durable => $self->service->queue_is_durable(),
      auto_delete => $self->service->queue_should_autodelete()
    };

    my $ping_config = {
      queue_name => '',
      routing_key => "ping",
      exchange_name => "amq.fanout",
      exchange_type => 'fanout',
      durable => 0,
      auto_delete => 1
    };

    $self->{ping_config} = $ping_config;

    $self->{amqp} = Net::RabbitFoot->new()->load_xml_spec()->connect(%$rabbitmq_opts);
    $self->{channels} = [];

    $self->_setup_processor($config, $self->service());
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


