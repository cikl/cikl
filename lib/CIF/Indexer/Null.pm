package CIF::Indexer::Null;
use strict;
use warnings;
use Mouse;
use CIF::Indexer::Role ();
use namespace::autoclean;

with "CIF::Indexer::Role";

sub index { 
  return 1;
}

sub index_array {
}

sub flush {
  return [];
}

__PACKAGE__->meta->make_immutable();
1;
