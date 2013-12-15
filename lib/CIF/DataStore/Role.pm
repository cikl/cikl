package CIF::DataStore::Role;
use strict;
use warnings;
use Mouse::Role;
use CIF::DataStore::Flusher ();
use namespace::autoclean;

sub shutdown {
  my $self = shift;
  $self->flush();
}

requires 'submit';
requires 'flush';

1;

