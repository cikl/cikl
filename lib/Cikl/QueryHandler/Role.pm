package Cikl::QueryHandler::Role;
use strict;
use warnings;
use Mouse::Role;
use namespace::autoclean;

requires 'search';

sub shutdown {
}

1;


