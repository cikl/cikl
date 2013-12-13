package CIF::Authentication::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF qw/debug/;
use namespace::autoclean;

requires 'authorized_write';
requires 'authorized_read';

sub shutdown {
}

1;


