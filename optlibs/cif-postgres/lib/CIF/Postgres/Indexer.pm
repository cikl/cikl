package CIF::Postgres::Indexer;
use strict;
use warnings;
use Mouse;
use CIF::Indexer::Role ();
use CIF::Postgres::SQLRole ();
use CIF::Postgres::IndexerSQL ();
use CIF::Codecs::JSON ();
use namespace::autoclean;

with "CIF::Indexer::Role", "CIF::Postgres::SQLRole";

has 'sql' => (
  is => 'ro',
  isa => 'CIF::Postgres::IndexerSQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_sql'
);

sub _build_sql {
  my $self = shift;
  return CIF::Postgres::IndexerSQL->new(dbh => $self->dbh);
}

sub index { 
  my $self = shift;
  my $submission = shift;
  $self->sql->queue_submission($submission);
  return 1;
}

sub flush {
  my $self = shift;
  return $self->sql->flush();
}

after "shutdown" => sub {
  my $self = shift;
  $self->sql->shutdown();
};

__PACKAGE__->meta->make_immutable();


1;

