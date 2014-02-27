use strict;
use warnings;

use inc::Module::Install;
use Getopt::Long;
use Data::Dumper;
require ExtUtils::MakeMaker;

our $DEF_DBNAME = 'cikl';
our $DEF_DBHOST = 'localhost';
our $DEF_DBPORT = 5432;
our $DEF_DBUSER = 'postgres';
our $DEF_DBPASS = '';
our $DEF_TABLESPACE = 'pg_default';
our $DEF_ARCHIVE_TABLESPACE = '' ;


###########

name 'cikl-postgres';
version '1.0';
license 'lgpl';

my $opts = parse_cli();

requires_external_bin('psql');
my $psql = can_run('psql');


preamble <<EOS
DB_UNIXOWNER=postgres
DB_USER=$opts->{'db-user'}
DB_PASS=$opts->{'db-pass'}
DB_NAME=$opts->{'db-name'}
DB_HOST=$opts->{'db-host'}
DB_PORT=$opts->{'db-port'}
DB_DEFAULT_TABLESPACE=$opts->{'db-default-tablespace'}
DB_ARCHIVE_TABLESPACE=$opts->{'db-archive-tablespace'}

ifndef DB_ARCHIVE_TABLESPACE
DB_ARCHIVE_TABLESPACE=\$(DB_DEFAULT_TABLESPACE)
endif

DB_TABLESPACE_PARAMS=--set ON_ERROR_STOP=1 --set "cikl_default_tablespace=\$(DB_DEFAULT_TABLESPACE)" --set "tablespace_archive=\$(DB_ARCHIVE_TABLESPACE)"
PSQL=$psql

PSQLX=\$(PSQL) \$(DB_TABLESPACE_PARAMS)
EOS
;

postamble <<EOS

create_tables:
\t\$(PSQLX) -d \$(DB_NAME) -U \$(DB_USER) -h \$(DB_HOST) -p \$(DB_PORT) -f schemas/Pg/datastore.sql
\t\$(PSQLX) -d \$(DB_NAME) -U \$(DB_USER) -h \$(DB_HOST) -p \$(DB_PORT) -f schemas/Pg/auth.sql
\t\$(PSQLX) -d \$(DB_NAME) -U \$(DB_USER) -h \$(DB_HOST) -p \$(DB_PORT) -f schemas/Pg/indexing.sql

create_db:
\t\$(PSQLX) -U \$(DB_USER) -h \$(DB_HOST) -p \$(DB_PORT) -c 'CREATE DATABASE \$(DB_NAME)'

initdb: create_db create_tables

drop_database:
\t\$(PSQLX) -U \$(DB_USER) -h \$(DB_HOST) -p \$(DB_PORT) -c 'DROP DATABASE IF EXISTS \$(DB_NAME)'

dropdb: drop_database

purgedb:
\t\$(PSQLX) -U \$(DB_USER) -h \$(DB_HOST) -p \$(DB_PORT) -d \$(DB_NAME) -f 'schemas/pg_purge.sql'
EOS
;

WriteAll;

sub parse_cli {
  Getopt::Long::Configure ("bundling");
  my $opt = {
    'db-name' => $DEF_DBNAME,
    'db-user' => $DEF_DBUSER,
    'db-pass' => $DEF_DBPASS,
    'db-host' => $DEF_DBHOST,
    'db-port' => $DEF_DBPORT,
    'db-default-tablespace' => $DEF_TABLESPACE,
    'db-archive-tablespace' => $DEF_ARCHIVE_TABLESPACE,
  };

  GetOptions(
    $opt,
    'help|?|h',
    'db-host=s',
    'db-port=i',
    'db-user=s',
    'db-pass=s',
    'db-name=s',
    'db-default-tablespace=s',
    'db-archive-tablespace=s',
  ) or usage();

  usage() if $opt->{help};
  return $opt;
}

sub usage() {
  print STDERR <<USAGE
Usage: perl $0 [options]

Possible options are:

  --db-name=<db>         Use the database <db>. defaults to '$DEF_DBNAME'
  --db-user=<user>       Use the username <user>. defaults to '$DEF_DBUSER'
  --db-pass=<pwd>        Use the password <pwd>. defaults to '$DEF_DBPASS'
  --db-host=<host>       Use <host> as a database server. defaults to 
                         '$DEF_DBHOST'
  --db-port=<port>       Use <port> as the port number of the database;
                         defaults to '$DEF_DBPORT'
  --help                 Print this message and exit

USAGE
;
  exit 1;
}

