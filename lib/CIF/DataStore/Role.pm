package CIF::DataStore::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF::Util::Flushable;
use namespace::autoclean;

with 'CIF::Util::Flushable';

requires 'submit';

sub shutdown {
}

sub checkpoint {
}

after 'submit' => sub {
  $_[0]->flusher->tick();
};


1;

