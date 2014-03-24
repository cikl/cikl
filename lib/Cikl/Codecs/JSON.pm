package Cikl::Codecs::JSON;

use strict;
use warnings;
use Cikl::Models::Submission;
use Cikl::Models::Event;
require JSON::XS;
use Mouse;
use Cikl::Codecs::CodecRole;
use namespace::autoclean;

our $JSON = JSON::XS->new()->utf8(1);

with 'Cikl::Codecs::CodecRole';

sub content_type {
  return "application/json";
}

sub encode_event {
  my $self = shift;
  my $event = shift;
  return $JSON->encode($event->to_hash());
}

sub decode_event {
  my $self = shift;
  my $json = shift;
  my $data = $JSON->decode($json);
  return Cikl::Models::Event->from_hash($data);
}

sub encode_submission {
  my $self = shift;
  my $submission = shift;

  return $JSON->encode($submission->to_hash());
}

sub decode_submission {
  my $self = shift;
  my $json = shift;
  my $data = $JSON->decode($json);
  return Cikl::Models::Submission->from_hash($data);
}

__PACKAGE__->meta->make_immutable;

1;
