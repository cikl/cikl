package CIF::Client::Transport::HTTP;
use base 'CIF::Client::HTTPCommonTransport';

use strict;
use warnings;

use CIF qw/debug/;
use CIF::MsgHelpers;

sub new {
    my $class = shift;
    my $args = shift;

    my $self = $class->SUPER::new($args);

    return $self;
}

sub _send_msg {
    my $self = shift;
    my $data = shift;

    my ($err, $resp) = $self->_http_post($data->encode(), 
      {'Content-Type' => 'application/x-protobuf'});

    return $err if($err);

    my $msg = MessageType->decode($resp);

    $err = CIF::MsgHelpers::get_msg_error($msg);
    return $err if ($err);

    return(undef, $msg);
}

sub query {
    my $self = shift;
    my $queries = shift;

    my $msg = CIF::MsgHelpers::msg_wrap_queries($queries);
    my ($err, $msg2) = $self->_send_msg($msg);

    return ($err) if (defined($err));

    return CIF::MsgHelpers::decode_msg_feeds($msg2);
}

sub submit {
    my $self = shift;
    my $apikey = shift;
    my $guid = shift;
    my $iodefs = shift;

    my $msg = CIF::MsgHelpers::build_submission_msg($apikey, $guid, $iodefs);
    my ($err, $ret) = $self->_send_msg($msg);
    return $err if ($err);
    return (undef, $ret->get_data());
}

1;
