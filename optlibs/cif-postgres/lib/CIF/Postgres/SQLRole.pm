package CIF::Postgres::SQLRole;
use strict;
use warnings;
use Mouse::Role;
use CIF::Postgres::SQL ();
use DBI ();
use namespace::autoclean;

has 'database' => (
  is => 'ro',
  isa => 'Str',
  default => sub { 'cif' }
);

has 'user' => (
  is => 'ro',
  isa => 'Str',
  default => sub { 'cif' }
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

has 'sql' => (
  is => 'ro',
  isa => 'CIF::Postgres::SQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_sql'
);

sub _build_sql {
  my $self = shift;
  my $connect_str = 'DBI:Pg:database='. $self->database.';host='.$self->host;
  my $dbh = DBI->connect($connect_str,$self->user,$self->password, {AutoCommit => 1});
  if (!$dbh) {
    die($!);
  }
  return CIF::Postgres::SQL->new(dbh => $dbh);
}

1;

