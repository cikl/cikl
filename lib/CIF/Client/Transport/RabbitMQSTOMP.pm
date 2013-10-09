package CIF::Client::Transport::RabbitMQSTOMP;
use base 'CIF::Client::Transport';

use strict;
use warnings;
use JSON qw{encode_json};
use Data::Dumper;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use Net::STOMP::Client;
use Net::STOMP::Client::Frame;
use Messaging::Message;
use CIF qw/debug/;
use CIF::MsgHelpers;

sub new {
    my $class = shift;
    my $args = shift;

    my $self = $class->SUPER::new($args);

    my $stomp = Net::STOMP::Client->new(uri => "stomp://localhost:61613/", 
    );
    $stomp->connect(login => "guest", passcode => "guest", "host" => "/");

    my $query_id = $stomp->uuid();

    $self->{query_id} = $query_id;
    $self->{stomp} = $stomp;
    $self->{dest_submit} = '/topic/cif-submit';
    $self->{dest_query} = '/topic/cif-query';
    my $uuid = $stomp->uuid();

    my $reply_queue = "/temp-queue/$uuid";

    $self->{reply_queue} = $reply_queue;

    return $self;
}

sub _queue_data {
    my $self = shift;
    my $dest = shift;
    my $body = shift;
    my $headers = shift || {};

    $headers->{destination} = $dest;
    my $frameopts = {
      body => $body
    };

    my $frame = Net::STOMP::Client::Frame->new(
        %$frameopts,
        command => "SEND",
        headers => $headers
    );

    $self->{stomp}->queue_frame($frame);
}

sub _queue_query {
    my $self = shift;
    my $body = shift;
    return $self->_queue_data(
      $self->{dest_query}, 
      $body, 
      {
        "reply-to" => $self->{reply_queue}
      }
    );
}

sub _queue_submission {
    my $self = shift;
    my $apikey = shift;
    my $guid = shift;
    my $iodef = shift;
    my $msg = CIF::MsgHelpers::build_submission_msg($apikey, $guid, [$iodef]);
    return $self->_queue_data(
      $self->{dest_submit}, 
      $msg->encode()
    );
}

sub _flush {
    my $self = shift;
    $self->{stomp}->send_data();
}

sub query {
    my $self = shift;
    my $queries = shift;
    my $msg = CIF::MsgHelpers::msg_wrap_queries($queries);

    $self->_queue_query($msg->encode());
    $self->_flush();


    while (my $frame = $self->{stomp}->wait_for_frames(timeout => 10)) {
      if ($frame->command() eq "MESSAGE") {
        my $msg2 = MessageType->decode($frame->body());

        return CIF::MsgHelpers::decode_msg_feeds($msg2);
      } else {
        warn "Unknown command type: ", $frame->command(), "\n";
      }
    }
    return("Timed out while waiting for reply.");
}

sub submit {
    my $self = shift;
    my $apikey = shift;
    my $guid = shift;
    my $iodefs = shift;

    my $uuids = CIF::MsgHelpers::get_uuids($iodefs);

    foreach my $iodef (@$iodefs) {
      $self->_queue_submission($apikey, $guid, $iodef);
    }
    $self->_flush();

    return (undef, $uuids);
}

1;


