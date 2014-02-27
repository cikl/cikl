package Cikl::Router::DataSubmissionRole;

use strict;
use warnings;
use Cikl qw/debug/;
use Cikl::DataStore::Role;
use Mouse::Role;
use namespace::autoclean;

has 'datastore' => (
  is => 'ro',
  isa => 'Cikl::DataStore::Role',
  required => 1
);
after 'shutdown' => sub {
  my $self = shift;
  $self->datastore->shutdown();
};

after 'checkpoint' => sub {
  my $self = shift;
  $self->datastore->checkpoint();
};

1;
