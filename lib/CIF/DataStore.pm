package CIF::DataStore;
use strict;
use warnings;
use Mouse::Role;
use CIF qw/debug/;
use namespace::autoclean;

has 'flusher' => (
  is => 'rw',
  isa => 'CIF::DataStore::Flusher',
  required => 0
);

sub shutdown {
  my $self = shift;
  $self->flusher()->flush();
}

requires 'submit';
requires 'search';
requires 'flush';
requires 'authorized_write';
requires 'authorized_read';

1;

