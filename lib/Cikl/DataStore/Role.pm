package Cikl::DataStore::Role;
use strict;
use warnings;
use Mouse::Role;
use Cikl::Util::Flushable;
use namespace::autoclean;

with 'Cikl::Util::Flushable';

requires 'submit';

sub shutdown {
}

sub checkpoint {
}

after 'submit' => sub {
  $_[0]->flusher->tick();
};


1;

