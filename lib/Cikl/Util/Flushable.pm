package Cikl::Util::Flushable;

use strict;
use warnings;
use Mouse::Role;
use Cikl::Util::Flusher;
use namespace::autoclean;

requires 'flush';
requires 'checkpoint';
requires 'shutdown';

has 'commit_interval' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);

has 'commit_size' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);

has 'flusher' => (
  is => 'ro',
  isa => 'Cikl::Util::Flusher',
  lazy_build => 1
);

sub _build_flusher {
  my $self = shift;
  return Cikl::Util::Flusher->new(
    commit_interval => $self->commit_interval,
    commit_size => $self->commit_size,
    flushable => $self
  );
}

sub add_flush_callback {
  my $self = shift;
  $self->flusher->add_flush_callback(@_);
}

before 'shutdown' => sub {
  my $self = shift;
  $self->flusher->flush();
};

after 'checkpoint' => sub {
  my $self = shift;
  $self->flusher->checkpoint();
};

1;

