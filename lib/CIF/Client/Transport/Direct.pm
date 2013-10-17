package CIF::Client::Transport::Direct;
use base 'CIF::Client::Transport';
use lib 'cif-router/lib';
use lib 'libcif-dbi/lib';

use strict;
use warnings;
use JSON qw{encode_json};
use Data::Dumper;
use CIF::Router;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use Messaging::Message;
use CIF qw/debug/;
use CIF::MsgHelpers;

sub new {
    my $class = shift;
    my $args = shift;

    $args->{driver_name} = "direct";

    my $self = $class->SUPER::new($args);
    
    # Initialize the router.
    my ($err,$router) = CIF::Router->new({
        config  => $self->get_global_config(),
      });
    if($err){
      ## TODO -- set debugging variable
      die $err;
    }

    $self->{router} = $router;

    return $self;
}

sub query {
    my $self = shift;
    my $queries = shift;
    print Dumper $queries;
    my $msg = CIF::MsgHelpers::msg_wrap_queries($queries);
    my $body = $msg->encode();

    my $response = $self->{router}->process($body);

    if (defined($response)) {
      return CIF::MsgHelpers::decode_msg_feeds(MessageType->decode($response));
    }
}

sub submit {
    my $self = shift;
    my $submission = shift;
    my $body = $self->encode_submission($submission);
    my $ret = $self->{router}->process($body);
    return (undef,$ret);
}

1;




