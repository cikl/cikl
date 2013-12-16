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

after 'shutdown' => sub {
  my $self = shift;
  $self->indexer->shutdown();
};

after 'checkpoint' => sub {
  my $self = shift;
  $self->indexer->checkpoint();
};

1;

