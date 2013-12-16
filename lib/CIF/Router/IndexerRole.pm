package CIF::Router::IndexerRole;

use strict;
use warnings;
use CIF qw/debug/;
use CIF::Indexer::Role;
use Mouse::Role;
use namespace::autoclean;

has 'indexer' => (
  is => 'ro',
  does => 'CIF::Indexer::Role',
  required => 1
);

has 'indexer_flusher' => (
  is => 'rw',
  isa => 'CIF::Indexer::Flusher',
  required => 1
);

after 'shutdown' => sub {
  my $self = shift;
  $self->indexer_flusher->flush();
  $self->indexer->shutdown();
};

1;

