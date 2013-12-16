package CIF::DataStore::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF::Util::Flushable;
use namespace::autoclean;

with 'CIF::Util::Flushable';

sub shutdown {
}

requires 'submit';

1;

