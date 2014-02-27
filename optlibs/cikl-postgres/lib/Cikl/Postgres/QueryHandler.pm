package Cikl::Postgres::QueryHandler;
use strict;
use warnings;
use Mouse;
use Cikl::QueryHandler::Role ();
use Cikl::Postgres::SQLRole ();
use Cikl::Postgres::QuerySQL ();
use Cikl::Codecs::JSON ();
use Cikl::Models::QueryResults ();
use namespace::autoclean;

with "Cikl::QueryHandler::Role", "Cikl::Postgres::SQLRole";

has 'sql' => (
  is => 'ro',
  isa => 'Cikl::Postgres::QuerySQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_sql'
);

sub _build_sql {
  my $self = shift;
  return Cikl::Postgres::QuerySQL->new(dbh => $self->dbh);
}


has '_db_codec' => (
  is => 'ro', 
  init_arg => undef,
  default => sub {Cikl::Codecs::JSON->new()}
);

sub search {
  my $self = shift;
  my $query = shift;
  my $arrayref_event_json = $self->sql->search($query);

  my $codec = $self->_db_codec;
  my $events = [ map { $codec->decode_event($_); } @$arrayref_event_json ];

  return Cikl::Models::QueryResults->new({
      query => $query,
      events => $events,
      reporttime => time(),
      group => $query->group()
    });
}

after "shutdown" => sub {
  my $self = shift;
  $self->sql->shutdown();
};

__PACKAGE__->meta->make_immutable();


1;
