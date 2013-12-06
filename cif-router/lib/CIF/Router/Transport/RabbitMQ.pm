package CIF::Router::Transport::RabbitMQ;
use base 'CIF::Router::Transport';

use strict;
use warnings;

use Net::RabbitFoot;
use AnyEvent;
use Coro;
use Try::Tiny;
use CIF qw/debug/;
use CIF::Router::Constants;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{exchange_name} = "amq.topic";

    my $rabbitmq_opts = {
      host => $self->config("host") || "localhost",
      port => $self->config("port") || 5672,
      user => $self->config("username") || "guest",
      pass => $self->config("password") || "guest",
      vhost => $self->config("vhost") || "/cif",
    };
    
    my $service_name = $self->service->name();

    my $config = {
      exchange_name => "amq.topic",
      exchange_type => "topic",
      queue_name => "$service_name-queue",
      routing_key =>  $service_name,
      durable => $self->service->queue_is_durable(),
      auto_delete => $self->service->queue_should_autodelete()
    };

    my $control_name = $self->control_service->name();

    my $control_config = {
      exchange_name => "control",
      exchange_type => "fanout",
      queue_name => "",
      routing_key =>  $control_name,
      durable => $self->control_service->queue_is_durable(),
      auto_delete => $self->control_service->queue_should_autodelete()
    };

    $self->{amqp} = Net::RabbitFoot->new()->load_xml_spec()->connect(%$rabbitmq_opts);
    $self->{channels} = [];

    $self->_setup_processor($config, $self->service());
    $self->_setup_processor($control_config, $self->control_service());
    return($self);
}

sub _init_channel {
    my $self = shift;
    my $channel = $self->{amqp}->open_channel();
    my $config = shift;
    my $service = shift;

    $channel->qos(prefetch_count => ($self->config("prefetch_count") || 1));

    $channel->declare_exchange(
      exchange => $config->{exchange_name},
      type => $config->{exchange_type},
      durable => 1,
      auto_delete => 0
    );
    $channel->qos(prefetch_count => 100);
    my $acker = CIF::Router::Transport::RabbitMQ::DeferredAcker->new(
      channel => $channel,
      max_outstanding => 100,
      timeout => 1
    );

    $self->_init_queue($channel, $config);
    $self->_init_consume($channel, $service, $acker);

    return $channel;
}

sub _init_consume {
    my $self = shift;
    my $channel = shift;
    my $service = shift;
    my $acker = shift;
    $channel->consume(
      no_ack => 0,
      on_consume => sub {
        $self->_handle_msg($channel, $_[0], $service, $acker);
      }
    );
}

sub _handle_msg {
    my $self = shift;
    my $channel = shift;
    my $msg = shift;
    my $service = shift;
    my $acker = shift;

    my $payload = $msg->{body}->payload;
    my ($reply, $type, $content_type, $err);

    try {
      ($reply, $type, $content_type) = $service->process($payload);
    } catch {
      $err = shift;
    };

    if ($err) {
      $reply = "Error while processing message: $err";
      $type = "error";
      $content_type = "text/plain";
      debug($reply);
      $acker->reject($msg->{deliver}->method_frame->delivery_tag);
    } else {
      $acker->ack($msg->{deliver}->method_frame->delivery_tag);
    }

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
      exchange => $config->{exchange_name},
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

package CIF::Router::Transport::RabbitMQ::DeferredAcker;
use strict;
use warnings;

use Moose;
use namespace::autoclean;
use CIF qw/debug/;

has 'channel' => (
  is => 'ro',
  #isa => ???,
  required => 1
);

has 'max_outstanding' => (
  is => 'ro',
  isa => 'Int',
  required => 1
);

has 'timeout' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);

has '_counter' => (
  traits  => ['Counter'],
  is => 'rw',
  isa => 'Int',
  init_arg => undef,
  default => 0,
  handles => {
    inc_counter   => 'inc',
    reset_counter => 'reset',
  }
);

has '_last_tag' => (
  is => 'rw',
  init_arg => undef
);

has '_timer' => (
  is => 'rw',
  init_arg => undef

);

sub ack {
  my $self = shift;
  $self->_last_tag(shift);
  $self->inc_counter();
  if ($self->_counter >= $self->max_outstanding()) {
    # Flush after X messages.
    $self->flush();
  } elsif (!defined($self->_timer)) {
    # Create timer that will flush for us.
    $self->_timer(AnyEvent->timer(
      after => $self->timeout, 
      cb => sub {$self->flush();}
    ));
  }
};

sub reject {
  my $self = shift;
  my $tag = shift;
  $self->flush();
  $self->channel->reject(delivery_tag => $tag);
}

sub flush {
  my $self = shift;
  $self->_timer(undef);
  $self->reset_counter();
  my $last_tag = $self->_last_tag;
  return if (!defined($last_tag));
  $self->channel->ack(delivery_tag => $last_tag, multiple => 1);
  $self->_last_tag(undef);
}

__PACKAGE__->meta->make_immutable();

1;


