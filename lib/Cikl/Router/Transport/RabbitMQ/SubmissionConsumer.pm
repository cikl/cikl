package Cikl::Router::Transport::RabbitMQ::SubmissionConsumer;
use strict;
use warnings;

use Cikl::Router::Transport::RabbitMQ::Consumer;
require Cikl::Codecs::JSON;
use Mouse;
use Cikl qw/debug/;
use namespace::autoclean;

extends 'Cikl::Router::Transport::RabbitMQ::Consumer';

has 'postprocess_key' => (
  is => 'ro', 
  isa => 'Str',
  required => 1
);

has 'postprocess_exchange' => (
  is => 'ro', 
  isa => 'Str',
  required => 1
);

has 'postprocess_codec' => (
  is => 'ro',
  isa => 'Cikl::Codecs::JSON',
  init_arg => undef,
  default => sub { Cikl::Codecs::JSON->new }
);

override 'handle_success' => sub {
  my $self = shift;
  my $args = shift;
  super();
  my $submission = $args->{decoded_payload};
  
  my $routing_key = $self->postprocess_key;
  my $address = $submission->event->address;
  if ($address) {
    $routing_key = $routing_key . "." . $address->type();
  }
  $self->channel->publish(
    # Note that we don't specify an exchange when replying.
    exchange => $self->postprocess_exchange,
    routing_key => $routing_key,
    body => $self->postprocess_codec->encode_submission($submission),
    header => {
      content_type => $self->postprocess_codec->content_type(),
    }
  );
};


__PACKAGE__->meta->make_immutable();

1;
