package Cikl::Postgres::DataStoreSQL;
use strict;
use warnings;
use Try::Tiny;
use Mouse;
use Cikl qw/debug/;
use List::MoreUtils qw/natatime/;
use namespace::autoclean;
use Time::HiRes qw/tv_interval gettimeofday/;
use Text::CSV_XS;

has 'dbh' => (
  is => 'ro',
  isa => 'DBI::db',
  required => 1
);

has 'last_flush' => (
  is => 'rw',
  init_arg => undef,
  default => sub { [gettimeofday] } 
);

has 'csv' => (
  is => 'ro',
  isa => 'Text::CSV_XS',
  init_arg => undef,
  required => 1,
  default => sub { Text::CSV_XS->new({eol => "\n"}) or die(Text::CSV_XS->error_diag); }
);

has "queued_submissions" => (
  traits => ['Array'],
  is => 'rw',
  isa => 'ArrayRef',
  default => sub {[]},
  handles => {
    num_queued_submissions => 'count',
    clear_queued_submissions => 'clear'
  }
);

sub queue_submission {
  my $self = shift;
  push(@{$self->queued_submissions}, shift);
}

has "insert_via_copy_sth" => (
  is => 'ro',
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(
      'COPY datastore (id,data) FROM STDIN WITH CSV'); }
);

has "get_ids_sth" => (
  is => 'ro',
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(
      "SELECT NEXTVAL('datastore_id_seq') FROM GENERATE_SERIES(1,?);"); }
);

sub get_ids {
  my $self = shift;
  my $num_ids = shift;
  my $sth = $self->get_ids_sth();
  $sth->execute($num_ids) or die($self->dbh->errstr);

  return $sth->fetchall_arrayref();
}

sub shutdown {
  my $self = shift;
  #$self->dbh->disconnect();
}

sub _insert_via_copy {
  my $self = shift;
  my $submissions = shift;
  my $sth = $self->insert_via_copy_sth;
  my $num_submissions = scalar(@$submissions);
  my $ids_arrayref = $self->get_ids($num_submissions);
  my $dbh = $self->dbh;
  $sth->execute() or die($dbh->errstr);
  my $buffer = "";
  my $csv = $self->csv();
  open(my $io, ">", \$buffer) or die($!);
  foreach my $submission (@$submissions) {
    my $submission_id = pop(@$ids_arrayref)->[0];
    $submission->datastore_id($submission_id);
    $csv->print($io, [$submission_id, $submission->event_json]);
  }
  $dbh->pg_putcopydata($buffer);
  $dbh->pg_endcopy;
  close($io) or die($!);
}

sub flush {
  my $self = shift;
  my $num_submissions = $self->num_queued_submissions();
  if ($num_submissions == 0) {
    return [];
  }
  my $err;
  my $dbh = $self->dbh;
  my $submissions = $self->queued_submissions();
  $self->_insert_via_copy($submissions);
  $self->queued_submissions([]);
  my $delta = tv_interval($self->last_flush);
  $self->last_flush([gettimeofday]);
  if ($err) {
    die($err);
  }
  my $rate = $num_submissions  / $delta;
  debug("Inserted $num_submissions, Submissions per second: $rate");
  return $submissions;
}

__PACKAGE__->meta->make_immutable();

1;

