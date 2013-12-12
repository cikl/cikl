package CIF::Codecs::JSON;

use strict;
use warnings;
use CIF::Models::Submission;
use CIF::Models::Event;
use CIF::Models::Query;
use CIF::Models::QueryResults;
use CIF::Models::HostInfo;
require JSON;
use Mouse;
use CIF::Codecs::CodecRole;
use namespace::autoclean;

our $JSON = JSON->new()->utf8(1);

with 'CIF::Codecs::CodecRole';

sub content_type {
  return "application/json";
}

sub encode_hostinfo {
  my $self = shift;
  my $hostinfo = shift;
  return $JSON->encode($hostinfo->to_hash());
}

sub decode_hostinfo {
  my $self = shift;
  my $json = shift;
  my $data = $JSON->decode($json);
  return CIF::Models::HostInfo->from_hash($data);
}

sub encode_query {
  my $self = shift;
  my $query = shift;
  return $JSON->encode($query->to_hash());
}

sub decode_query {
  my $self = shift;
  my $json = shift;
  return CIF::Models::Query->from_hash($JSON->decode($json));
}

sub encode_query_results {
  my $self = shift;
  my $query_results = shift;
  return($JSON->encode($query_results->to_hash()));

}

sub decode_query_results {
  my $self = shift;
  my $json = shift;
  my $data = $JSON->decode($json);
  my $query_results = CIF::Models::QueryResults->from_hash($data);

  return ($query_results);
}

sub encode_event {
  my $self = shift;
  my $event = shift;
  my $e = $event->to_hash();
  return $JSON->encode($event->to_hash());
}

sub decode_event {
  my $self = shift;
  my $json = shift;
  my $data = $JSON->decode($json);
  return CIF::Models::Event->from_hash($data);
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
  return CIF::Models::Submission->from_hash($data);
}

__PACKAGE__->meta->make_immutable;

1;
