package Cikl::Postgres::IndexerSQL;
use strict;
use warnings;
use Try::Tiny;
use Mouse;
use Cikl qw/debug/;
use namespace::autoclean;
use Time::HiRes qw/tv_interval gettimeofday/;
use Text::CSV_XS;

use constant INDEX_TYPE_MAP => {
  asn => 'asn',
  email => 'email',
  fqdn => 'fqdn',
  ipv4 => 'cidr',
  ipv4_cidr => 'cidr',
  url => 'url'
};

has 'dbh' => (
  is => 'ro',
  isa => 'DBI::db',
  required => 1
);

has 'csv' => (
  is => 'ro',
  isa => 'Text::CSV_XS',
  init_arg => undef,
  required => 1,
  default => sub { Text::CSV_XS->new({eol => "\n"}) or die(Text::CSV_XS->error_diag); }
);

has 'last_flush' => (
  is => 'rw',
  init_arg => undef,
  default => sub { [gettimeofday] } 
);

has "queued_submissions" => (
  traits => ['Array'],
  is => 'ro',
  isa => 'ArrayRef',
  default => sub {[]},
  handles => {
    num_queued_submissions => 'count',
    clear_queued_submissions => 'clear'
  }
);

has "index_main_copy_sth" => (
  is => 'ro',
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(
      'COPY cikl_index_main (id,group_name,created,reporttime,assessment,confidence) 
      FROM STDIN WITH CSV'); }
);
for my $INDEX (qw(asn cidr email fqdn url)) {
  has "${INDEX}s" => (
    traits => ['Array'],
    is => 'ro',
    isa => 'ArrayRef',
    default => sub {[]},
    handles => {
      "num_${INDEX}s" => 'count',
      "clear_${INDEX}s" => 'clear'
    }
  );

  has "index_${INDEX}_copy_sth" => (
    is => 'ro',
    lazy => 1,
    default => sub { $_[0]->dbh->prepare(
        "COPY cikl_index_${INDEX} (id, ${INDEX}) FROM STDIN WITH CSV"); }
  );
}

sub queue_submission {
  my $self = shift;
  my $submission = shift;
  my $event = $submission->event();
  my $id = $submission->datastore_id();
  if (!defined($id)) {
    die("datastore_id is required for indexing!");
  }

  if (my $address = $event->address()) {
    if (my $index = INDEX_TYPE_MAP->{$address->type()}) {
      if ($index eq 'asn') {
        push(@{$self->asns}, [$id, $address->value()])
      } elsif ($index eq 'cidr') {
        push(@{$self->cidrs}, [$id, $address->value()])
      } elsif ($index eq 'email') {
        push(@{$self->emails}, [$id, $address->value()])
      } elsif ($index eq 'fqdn') {
        push(@{$self->fqdns}, [$id, $address->value()])
      } elsif ($index eq 'url') {
        push(@{$self->urls}, [$id, $address->value()])
      }
      #QUEUE_ADDRESS->{$index}->($self, $id, $address->value());
    };
  }
  push(@{$self->queued_submissions}, 
    [
      $id,
      $event->group, 
      $event->detecttime, 
      $event->reporttime,
      $event->assessment,
      $event->confidence
    ]);
}

sub shutdown {
  my $self = shift;
  #$self->dbh->disconnect();
}

sub _insert_via_copy {
  my $self = shift;
  my $rows = shift;
  my $sth = shift;
  my $dbh = $self->dbh;
  $sth->execute() or die($dbh->errstr);
  my $buffer = "";
  my $csv = $self->csv();
  open(my $io, ">", \$buffer) or die($!);
  foreach my $row (@$rows) {
    $csv->print($io,  $row);
    #$dbh->pg_putline (join ("\t", @$row) . "\n");
  }
  $dbh->pg_putcopydata($buffer);
  $dbh->pg_endcopy;
  close($io) or die($!);
}

sub flush {
  my $self = shift;
  my $num_submissions = $self->num_queued_submissions();
  if ($num_submissions == 0) {
    return undef;
  }
  my $err;
  my $dbh = $self->dbh;
  my $start = [gettimeofday];
  $dbh->begin_work() or die($dbh->errstr);
  try {
    $self->_insert_via_copy($self->queued_submissions, $self->index_main_copy_sth);
    $self->clear_queued_submissions();
    if ($self->num_asns()) {
      $self->_insert_via_copy($self->asns(), $self->index_asn_copy_sth);
      $self->clear_asns();
    }
    if ($self->num_cidrs()) {
      $self->_insert_via_copy($self->cidrs(), $self->index_cidr_copy_sth);
      $self->clear_cidrs();
    }
    if ($self->num_emails()) {
      $self->_insert_via_copy($self->emails(), $self->index_email_copy_sth);
      $self->clear_emails();
    }
    if ($self->num_fqdns()) {
      $self->_insert_via_copy($self->fqdns(), $self->index_fqdn_copy_sth);
      $self->clear_fqdns();
    }
    if ($self->num_urls()) {
      $self->_insert_via_copy($self->urls(), $self->index_url_copy_sth);
      $self->clear_urls();
    }
    $dbh->commit();
  } catch {
    $err = shift;
    $dbh->rollback();
  };
  my $delta = tv_interval($self->last_flush);
  my $delta_local = tv_interval($start);
  $self->last_flush([gettimeofday]);
  if ($err) {
    die($err);
  }
  my $rate = $num_submissions  / $delta;
  my $rate_local = $num_submissions / $delta_local;
  
  debug("Index  Events per second: $rate / Local: $rate_local");
}

__PACKAGE__->meta->make_immutable();

1;


