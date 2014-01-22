package CIF::Indexer::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF::Util::Flushable;
use namespace::autoclean;

with "CIF::Util::Flushable";

requires 'index';

sub index_array {
  my $self = shift;
  my $submissions = shift;

  foreach my $submission (@$submissions) {
    $self->index($submission);
  }
}

sub shutdown {
}

sub checkpoint {
}

after 'index' => sub {
  $_[0]->flusher->tick();
};
1;


