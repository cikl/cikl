package Cikl::Router::AuthenticatedRole;

use strict;
use warnings;
use Cikl qw/debug/;
use Cikl::Authentication::Role;
use Mouse::Role;
use namespace::autoclean;

has 'auth' => (
  is => 'ro',
  isa => 'Cikl::Authentication::Role',
  required => 1
);

after 'shutdown' => sub {
  my $self = shift;
  $self->auth->shutdown();
};

1;
