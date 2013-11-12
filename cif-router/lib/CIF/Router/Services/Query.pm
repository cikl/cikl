package CIF::Router::Services::Query;
use parent 'CIF::Router::Service';

use strict;
use warnings;
use CIF::Router::Constants;
use Try::Tiny;
use CIF qw/debug/;

sub service_type { SVC_QUERY }

# Should return 1 or 0
sub queue_should_autodelete {
  return 1;
}

# Should return 1 or 0
sub queue_is_durable {
  return 0;
}

# Should return 1 or 0
sub service_requests_are_broadcast {
  return 0;
}

sub process {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($query, $results, $encoded_results);
  try {
    $query = $self->encoder->decode_query($payload);
    $results = $self->router->process_query($query);
    $encoded_results = $self->encoder->encode_query_results($results);
  } catch {
    my $err = shift;
    debug($err);
    return($err, "query_error", 'text/plain');
  };
  return($encoded_results, "query_response", $self->encoder->content_type());
}
1;


