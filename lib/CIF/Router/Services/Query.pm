package CIF::Router::Services::Query;

use strict;
use warnings;
use CIF::Router::ServiceRole;
use CIF::Router::AuthenticatedRole;
use CIF::Router::Constants;
use Try::Tiny;
use CIF qw/debug/;
use Mouse;
with 'CIF::Router::ServiceRole', 
     'CIF::Router::AuthenticatedRole',
     'CIF::Router::QueryHandlingRole'
     ;

use namespace::autoclean;

sub service_type { CIF::Router::Constants::SVC_QUERY }

sub process {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($query, $results, $encoded_results, $err);
  try {
    $query = $self->codec->decode_query($payload);
  } catch {
    $err = shift;
  };
  if ($err) {
    die("Error while trying to decode query: $err");
  }

  my $apikey_info = $self->auth->authorized_read(
    $query->apikey, $query->group());

  if (!defined($query->group())) {
    $query->group($apikey_info->{'default_group'});
  }

  try {
    $results = $self->query_handler->search($query);
  } catch {
    $err = shift;
  };
  if ($err) {
    die("Error while trying to process query: $err");
  }

  try {
    $encoded_results = $self->codec->encode_query_results($results);
  } catch {
    $err = shift;
  };
  if ($err) {
    die("Error while trying to encode query results: $err");
  }
  return($encoded_results, "query_response", $self->codec->content_type(), 0);
}

__PACKAGE__->meta->make_immutable();

1;
