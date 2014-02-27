package Cikl::Postgres::SQLRole;
use strict;
use warnings;
use Mouse::Role;
use DBI ();
use namespace::autoclean;

has 'database' => (
  is => 'ro',
  isa => 'Str',
  default => sub { 'cikl' }
);

has 'user' => (
  is => 'ro',
  isa => 'Str',
  default => sub { 'cikl' }
);

has 'password' => (
  is => 'ro',
  isa => 'Str',
  default => sub { '' }
);

has 'host' => (
  is => 'ro',
  isa => 'Str',
  default => sub { 'localhost' }
);

has 'dbh' => (
  is => 'ro',
  isa => 'DBI::db',
  init_arg => undef,
  lazy => 1,
  builder => '_build_dbh'
);

sub _build_dbh {
  my $self = shift;
  my $connect_str = 'DBI:Pg:database='. $self->database.';host='.$self->host;
  my $dbh = DBI->connect($connect_str,$self->user,$self->password, {AutoCommit => 1});
  if (!$dbh) {
    die($!);
  }
  return $dbh;
}

1;

