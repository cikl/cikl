package CIF::DataStore;
use strict;
use warnings;
use Mouse::Role;
use namespace::autoclean;

requires 'submit';
requires 'search';
requires 'flush';
requires 'shutdown';

requires 'authorized_write';
requires 'authorized_read';

1;

