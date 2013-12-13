package CIF::QueryHandler::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF::DataStore::Flusher ();
use namespace::autoclean;

requires 'search';

sub shutdown {
}

1;


