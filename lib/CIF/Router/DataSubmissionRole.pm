package CIF::Router::DataSubmissionRole;

use strict;
use warnings;
use CIF qw/debug/;
use CIF::DataStore::Role;
use CIF::Util::Flusher;
use Mouse::Role;
use namespace::autoclean;

has 'datastore' => (
  is => 'ro',
  isa => 'CIF::DataStore::Role',
  required => 1
);

has 'flusher' => (
  is => 'rw',
  isa => 'CIF::Util::Flusher',
  required => 1
);

after 'shutdown' => sub {
  my $self = shift;
  $self->flusher->flush();
  $self->datastore->shutdown();
};

after 'checkpoint' => sub {
  my $self = shift;
  $self->flusher->checkpoint();
};

1;
