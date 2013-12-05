package CIF::DataStore;
use strict;
use warnings;
use Moose::Role;
use namespace::autoclean;

requires 'insert_event';
requires 'search';
requires 'flush';
requires 'shutdown';

1;

