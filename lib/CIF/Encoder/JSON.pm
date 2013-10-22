package CIF::Encoder::JSON;

use strict;
use warnings;
use CIF::MsgHelpers;
use CIF::Models::Submission;
use CIF::Models::Event;
use CIF::Models::Query;
use CIF::Client::Query;
use Try::Tiny;
require JSON;

sub new {
  my $class = shift;
  my $self = {};
  bless($self,$class);
  return $self;
}

sub encode_query {
  my $self = shift;
  my $query = shift;
  my $data = {};
  map { $data->{$_} = $query->{$_} } keys %{$query};
  return JSON::encode_json($data);
}

sub decode_query {
  my $self = shift;
  my $json = shift;
  my $data = JSON::decode_json($json);
  return CIF::Models::Query->new($data);
}

sub encode_answer {
  my $self = shift;
  my $answer = shift;
  return $answer->encode();
}

sub decode_answer {
  my $self = shift;
  my $data = shift;
  return CIF::MsgHelpers::decode_msg_feeds(MessageType->decode($data));
}

sub encode_event {
  my $self = shift;
  my $event = shift;
  my $e = $event->to_hash();
  return JSON::encode_json($event->to_hash());
}

sub decode_event {
  my $self = shift;
  my $json = shift;
  my $data = JSON::decode_json($json);
  return CIF::Models::Event->from_hash($data);
}

sub encode_submission {
  my $self = shift;
  my $submission = shift;

  return JSON::encode_json($submission->to_hash());
}

sub decode_submission {
  my $self = shift;
  my $json = shift;
  my $data = JSON::decode_json($json);
  return CIF::Models::Submission->from_hash($data);
}


1;
