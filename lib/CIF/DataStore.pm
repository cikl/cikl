package CIF::DataStore;
use strict;
use warnings;
use Mouse::Role;
use namespace::autoclean;

requires 'submit';
requires 'insert_event';
requires 'search';
requires 'flush';
requires 'shutdown';

1;

