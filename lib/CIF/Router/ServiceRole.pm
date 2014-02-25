package CIF::Router::ServiceRole;

use strict;
use warnings;
use CIF qw/debug/;
use CIF::Router::Constants;
use Mouse::Role;
use Try::Tiny;
use namespace::autoclean;

has 'codec' => (
  is => 'ro',
  isa => 'CIF::Codecs::CodecRole',
  required => 1
);

has 'starttime' => (
  is => 'ro', 
  isa => 'Num',
  init_arg => undef,
  default => sub { time() }
);

requires "service_type";
requires "decode_payload";
requires "do_work";
requires "encode_response";
requires "response_type";

sub name {
  my $class = shift;
  return CIF::Router::Constants::SVCNAMES->{$class->service_type()};
}

sub uptime {
  my $self = shift;
  return time() - $self->starttime();
}

sub checkpoint {
}

sub shutdown {
}

sub process {
  my $self = shift;
  my $args = shift || {};
  my $payload = $args->{payload} || die("Missing payload argument");
  my $on_success = $args->{on_success} || die("Missing on_success callback");
  my $on_failure = $args->{on_failure} || die("Missing on_failure callback");
  my $callback_data = $args->{callback_data};
  my ($decoded_payload, $work_results, $encoded_work_results, $err);

  try {
    $decoded_payload = $self->decode_payload($payload);
  } catch {
    $err = shift;
  };

  if ($err) {
    $on_failure->({callback_data => $callback_data, error => "Error while trying to decode: $err" } );
    return;
  }

  try {
    $work_results = $self->do_work($decoded_payload);
  } catch {
    $err = shift;
  };
  if ($err) {
    $on_failure->({callback_data => $callback_data, error => "Error while trying to process: $err" });
    return;
  }

  try {
    $encoded_work_results = $self->encode_response($work_results);
  } catch {
    $err = shift;
  };

  if ($err) {
    $on_failure->({ callback_data => $callback_data, error => "Error while trying to encode results: $err" });
    return;
  }
  $on_success->( {
    callback_data => $callback_data, 
    decoded_payload => $decoded_payload,
    work_results => $work_results,
    encoded_work_results => $encoded_work_results, 
    response_type => $self->response_type(), 
    content_type => $self->response_content_type()
  } );
  return;
}

sub response_content_type {
  my $self = shift;
  if (defined($self->{_content_type_})) {
      return $self->{_content_type_};
    }
  $self->{_content_type_} = $self->codec->content_type();
  return $self->{_content_type_};
}

1;
