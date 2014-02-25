package CIF::Router::Services::Query;

use strict;
use warnings;
use CIF::Router::ServiceRole;
use CIF::Router::AuthenticatedRole;
use CIF::Router::Constants;
use CIF qw/debug/;
use Mouse;
with 'CIF::Router::ServiceRole', 
     'CIF::Router::AuthenticatedRole',
     'CIF::Router::QueryHandlingRole'
     ;

use namespace::autoclean;

sub service_type { CIF::Router::Constants::SVC_QUERY }

sub decode_payload {
  return $_[0]->codec->decode_query($_[1]);
}

sub do_work {
  my $self = shift;
  my $query = shift;

  my $apikey_info = $self->auth->authorized_read(
    $query->apikey, $query->group());

  if (!defined($query->group())) {
    $query->group($apikey_info->{'default_group'});
  }

  return $self->query_handler->search($query);
}

sub encode_response {
  my $self = shift;
  my $results = shift;
  return $self->codec->encode_query_results($results);
}

use constant RESPONSE_TYPE => "query_response";
sub response_type {
  return RESPONSE_TYPE;
}

__PACKAGE__->meta->make_immutable();

1;
