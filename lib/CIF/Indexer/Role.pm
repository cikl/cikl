package CIF::Indexer::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF::DataStore::Flusher ();
use namespace::autoclean;

sub shutdown {
}

requires 'index';
requires 'flush';

1;


