package Cikl::Client::Transport;

use strict;
use warnings;
use Mouse::Role;
use Scalar::Util qw(blessed);
use Cikl::Codecs::JSON;
use Cikl::Models::Submission;
use namespace::autoclean;
use Cikl qw/debug/;

has 'codec' => (
  is => 'ro',
  default => sub { Cikl::Codecs::JSON->new() } 
);

has 'running' => (
  is => 'rw',
  default => 1
);

sub DEMOLISH {
    my $self = shift;
    $self->shutdown();
}

sub encode_event {
  my $self = shift;
  my $event = shift;
  return $self->codec->encode_event($event);
}

sub encode_submission {
  my $self = shift;
  my $submission = shift;
  return $self->codec->encode_submission($submission);
}

sub shutdown {
}

requires '_submit';

1;

