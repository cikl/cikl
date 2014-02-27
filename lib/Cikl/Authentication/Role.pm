package Cikl::Authentication::Role;
use strict;
use warnings;
use Mouse::Role;
use Cikl qw/debug/;
use namespace::autoclean;

requires 'authorized_write';
requires 'authorized_read';

sub shutdown {
}

1;


