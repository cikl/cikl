package Cikl::Router::QueryHandlingRole;

use strict;
use warnings;
use Cikl qw/debug/;
use Cikl::QueryHandler::Role;
use Mouse::Role;
use namespace::autoclean;

has 'query_handler' => (
  is => 'ro',
  isa => 'Cikl::QueryHandler::Role',
  required => 1
);

after 'shutdown' => sub {
  my $self = shift;
  $self->query_handler->shutdown();
};

1;
