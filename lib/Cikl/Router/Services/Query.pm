package Cikl::Router::Services::Query;

use strict;
use warnings;
use Cikl::Router::ServiceRole;
use Cikl::Router::AuthenticatedRole;
use Cikl::Router::Constants;
use Cikl qw/debug/;
use Mouse;
with 'Cikl::Router::ServiceRole', 
     'Cikl::Router::AuthenticatedRole',
     'Cikl::Router::QueryHandlingRole'
     ;

use namespace::autoclean;

sub service_type { Cikl::Router::Constants::SVC_QUERY }

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
