package CIF::DataStore::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF::DataStore::Flusher ();
use namespace::autoclean;

sub shutdown {
}

requires 'submit';
requires 'flush';

1;

