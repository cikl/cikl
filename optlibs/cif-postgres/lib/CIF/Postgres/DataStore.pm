package CIF::Postgres::DataStore;
use strict;
use warnings;
use Mouse;
use CIF::DataStore::Role ();
use CIF::Postgres::SQLRole ();
use CIF::Postgres::DataStoreSQL ();
use CIF::Postgres::IndexerSQL ();
use CIF::Codecs::JSON ();
use namespace::autoclean;

with "CIF::DataStore::Role", "CIF::Postgres::SQLRole";

has 'sql' => (
  is => 'ro',
  isa => 'CIF::Postgres::DataStoreSQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_sql'
);

has 'indexer_sql' => (
  is => 'ro',
  isa => 'CIF::Postgres::IndexerSQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_indexer_sql'
);

sub _build_sql {
  my $self = shift;
  return CIF::Postgres::DataStoreSQL->new(dbh => $self->dbh);
}

sub _build_indexer_sql {
  my $self = shift;
  return CIF::Postgres::IndexerSQL->new(dbh => $self->dbh);
}

has '_db_codec' => (
  is => 'ro', 
  init_arg => undef,
  default => sub {CIF::Codecs::JSON->new()}
);

sub submit { 
  my $self = shift;
  my $submission = shift;
  $self->sql->queue_submission($submission);
  return 1;
}

sub flush {
  my $self = shift;
  my $ret = $self->sql->flush();
  foreach my $thing (@$ret) {
    $self->indexer_sql->queue_submission($thing);
  }
  $self->indexer_sql->flush();
  return $ret;
}

after "shutdown" => sub {
  my $self = shift;
  $self->sql->shutdown();
  $self->indexer_sql->shutdown();
  $self->dbh->disconnect();
};

__PACKAGE__->meta->make_immutable();


1;
