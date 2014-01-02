package CIF::Client::Transport;

use strict;
use warnings;
use Mouse::Role;
use Scalar::Util qw(blessed);
use CIF::Codecs::JSON;
use CIF::Models::Submission;
use namespace::autoclean;
use CIF qw/debug/;

has 'codec' => (
  is => 'ro',
  default => sub { CIF::Codecs::JSON->new() } 
);

has 'running' => (
  is => 'rw',
  default => 1
);

sub DEMOLISH {
    my $self = shift;
    $self->shutdown();
}

sub encode_hostinfo {
  my $self = shift;
  my $hostinfo = shift;
  return $self->codec->encode_submission($hostinfo);
}

sub encode_submission {
  my $self = shift;
  my $submission = shift;
  return $self->codec->encode_submission($submission);
}

sub encode_query {
  my $self = shift;
  my $query = shift;
  return $self->codec->encode_query($query);
}

sub decode_query_results {
  my $self = shift;
  my $content_type = shift;
  my $answer = shift;
  return $self->codec->decode_query_results($answer);
}

sub decode_hostinfo {
  my $self = shift;
  my $content_type = shift;
  my $answer = shift;
  return $self->codec->decode_hostinfo($answer);
}

sub shutdown {
}

requires '_query';
requires '_submit';
requires '_ping';

1;

