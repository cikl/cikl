package CIF::Codecs::JSON;

use strict;
use warnings;
use CIF::Models::Submission;
use CIF::Models::Event;
use CIF::Models::Query;
use CIF::Models::QueryResults;
use CIF::Models::HostInfo;
require JSON;
use Moose;
use CIF::Codecs::CodecRole;
use namespace::autoclean;

with 'CIF::Codecs::CodecRole';

sub content_type {
  return "application/json";
}

sub encode_hostinfo {
  my $self = shift;
  my $hostinfo = shift;
  return JSON::encode_json($hostinfo->to_hash());
}

sub decode_hostinfo {
  my $self = shift;
  my $json = shift;
  my $data = JSON::decode_json($json);
  return CIF::Models::HostInfo->from_hash($data);
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

sub encode_query_results {
  my $self = shift;
  my $query_results = shift;
  return(JSON::encode_json($query_results->to_hash()));

}

sub decode_query_results {
  my $self = shift;
  my $json = shift;
  my $data = JSON::decode_json($json);
  my $query_results = CIF::Models::QueryResults->from_hash($data);

  return ($query_results);
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

__PACKAGE__->meta->make_immutable;

1;
