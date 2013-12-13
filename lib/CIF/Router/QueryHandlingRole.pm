package CIF::Router::QueryHandlingRole;

use strict;
use warnings;
use CIF qw/debug/;
use CIF::QueryHandler::Role;
use Mouse::Role;
use namespace::autoclean;

has 'query_handler' => (
  is => 'ro',
  isa => 'CIF::QueryHandler::Role',
  required => 1
);

after 'shutdown' => sub {
  my $self = shift;
  $self->query_handler->shutdown();
};

1;
