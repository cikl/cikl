package CIF::Router::AuthenticatedRole;

use strict;
use warnings;
use CIF qw/debug/;
use CIF::Authentication::Role;
use Mouse::Role;
use namespace::autoclean;

has 'auth' => (
  is => 'ro',
  isa => 'CIF::Authentication::Role',
  required => 1
);

after 'shutdown' => sub {
  my $self = shift;
  $self->auth->shutdown();
};

1;
