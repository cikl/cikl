package CIF::Router::Transport::RabbitMQ::SubmissionConsumer;
use strict;
use warnings;

use CIF::Router::Transport::RabbitMQ::Consumer;
require CIF::Codecs::JSON;
use Mouse;
use CIF qw/debug/;
use namespace::autoclean;

extends 'CIF::Router::Transport::RabbitMQ::Consumer';

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
  isa => 'CIF::Codecs::JSON',
  init_arg => undef,
  default => sub { CIF::Codecs::JSON->new }
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
