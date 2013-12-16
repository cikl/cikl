package CIF::Router::DataSubmissionRole;

use strict;
use warnings;
use CIF qw/debug/;
use CIF::DataStore::Role;
use Mouse::Role;
use namespace::autoclean;

has 'datastore' => (
  is => 'ro',
  isa => 'CIF::DataStore::Role',
  required => 1
);

has 'flusher' => (
  is => 'rw',
  isa => 'CIF::DataStore::Flusher',
  required => 1
);

after 'shutdown' => sub {
  my $self = shift;
  $self->flusher->flush();
  $self->datastore->shutdown();
};

1;
