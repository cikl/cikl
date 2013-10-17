package CIF::Client::Transport::RabbitMQ;
use base 'CIF::Client::Transport';

use strict;
use warnings;
use JSON qw{encode_json};
use Data::Dumper;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use Net::RabbitFoot;
use Messaging::Message;
use CIF qw/debug/;
use CIF::MsgHelpers;

sub new {
    my $class = shift;
    my $args = shift;
    $args->{driver_name} = "rabbitmq";

    my $self = $class->SUPER::new($args);


    my $amqp = Net::RabbitFoot->new()->load_xml_spec()->connect(
      host => 'localhost',
      port => 5672,
      user => 'guest',
      pass => 'guest',
      vhost => '/',
    );
    my $channel = $amqp->open_channel();

    $self->{exchange_name} = "cif";
    $self->{submit_key} = "submit";
    $self->{query_key} = "query";
    $self->{amqp} = $amqp;
    $self->{channel} = $channel;

    return $self;
}

sub query {
    my $self = shift;
    my $queries = shift;
    my $msg = CIF::MsgHelpers::msg_wrap_queries($queries);
    my $body = $msg->encode();

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
          $cv->send($resp->{body}->{payload});
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
      return CIF::MsgHelpers::decode_msg_feeds(MessageType->decode($response));
    } else {
      return("Timed out while waiting for reply.");
    }
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



