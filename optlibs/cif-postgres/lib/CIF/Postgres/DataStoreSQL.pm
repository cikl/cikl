package CIF::Postgres::DataStoreSQL;
use strict;
use warnings;
use Try::Tiny;
use Mouse;
use CIF qw/debug/;
use List::MoreUtils qw/natatime/;
use namespace::autoclean;
use Time::HiRes qw/tv_interval gettimeofday/;

use constant INDEX_SIZES => (2000, 1000, 500, 100, 1);
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

has 'last_flush' => (
  is => 'rw',
  init_arg => undef,
  default => sub { [gettimeofday] } 
);

sub build_insert_event_sql {
  my $count = shift;
  my @values;
  for (my $i = 0; $i < $count; $i++) {
     push(@values, "(?)");
  }
  return "INSERT INTO datastore (data) VALUES " . 
    join(",", @values) . 
    ' RETURNING id;';
}

sub build_index_event_sql {
  my $count = shift;
  my @values;
  for (my $i = 0; $i < $count; $i++) {
     push(@values, "(?,?,?,?,?,?,?,?,?,?,?)");
  }
  return "INSERT INTO indexing (id,group_name,created,reporttime,assessment,confidence,asn,cidr,email,fqdn,url) VALUES " . 
    join(",", @values) . ';';
}


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

sub queue_submission {
  my $self = shift;
  push(@{$self->queued_submissions}, shift);
}

has 'inserter_sth_map' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  lazy => 1,
  builder => '_build_inserters'
);

has 'indexer_sth_map' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  lazy => 1,
  builder => '_build_indexers'
);

sub _build_inserters {
  my $self = shift;
  my $column = shift;
  my $ret = {};
  foreach my $count (INDEX_SIZES) {
    $ret->{$count} = $self->dbh->prepare(build_insert_event_sql($count)),
  }
  return $ret;
}

sub _build_indexers {
  my $self = shift;
  my $ret = {};
  foreach my $count (INDEX_SIZES) {
    $ret->{$count} = $self->dbh->prepare(build_index_event_sql($count)),
  }
  return $ret;
}

sub shutdown {
  my $self = shift;
  $self->flush();
  $self->dbh->disconnect();
}

sub do_insert_submissions {
  my $self = shift;
  my $sth = shift;
  my $submissions = shift;
  my @values;
  foreach my $submission (@$submissions) {
    push(@values, 
      $submission->event_json, 
    );
  }
  $sth->execute(@values) or die($self->dbh->errstr);

  my $ids = $sth->fetchall_arrayref();

  # Map out only the id column;
  $ids = [map { $_->[0]; } @$ids];

  return $ids;
}

sub do_index_submissions {
  my $self = shift;
  my $sth = shift;
  my $submissions = shift;
  my $ids = shift;
  my @values;
  my $num_submissions = scalar(@$submissions);
  for (my $i = 0; $i < $num_submissions; $i++) {
    my $event = $submissions->[$i]->event();
    my $id = $ids->[$i];

    my $addresses = {};
    foreach my $address (@{$event->addresses()}) {
      my $index = INDEX_TYPE_MAP->{$address->type()} 
          or die("Unknown type: " . $address->type());
      my $x = ($addresses->{$index} ||= []);
      push(@$x, $address->value());
    }
    push(@values, 
      $id,
      $event->group, 
      $event->detecttime, 
      $event->reporttime,
      $event->assessment,
      $event->confidence,
      $addresses->{asn},
      $addresses->{cidr},
      $addresses->{email},
      $addresses->{fqdn},
      $addresses->{url},
    );
  }
  $sth->execute(@values) or die($self->dbh->errstr);
}

sub _insert_submissions {
  my $self = shift;
  my $submissions = shift;
  my $sths = $self->inserter_sth_map;
  my $index_sths = $self->indexer_sth_map;
  my $sth;
  my $index_sth;
  my $chunk_size;
  my $it;
  my $num_submissions = scalar(@$submissions);
  my $remaining_submissions = [];

  while ($num_submissions > 0) {
    foreach my $sz (INDEX_SIZES) {
      if ($num_submissions > $sz) {
        $chunk_size = $sz;
        last;
      }
    }
    if (!defined($chunk_size)) {
      die("Undefined chunk size!");
    }
    $sth = $sths->{$chunk_size} or die("Bad chunk size: $chunk_size");
    $index_sth = $index_sths->{$chunk_size} or die("Bad chunk size: $chunk_size");
    $it = natatime($chunk_size, @$submissions);
    CHUNKER: while (my @chunk = $it->()) {
      my $x = scalar(@chunk);
      if ($x == $chunk_size) {
        my $ids = $self->do_insert_submissions($sth, \@chunk);
        $self->do_index_submissions($index_sth, \@chunk, $ids);
      } else {
        $remaining_submissions = \@chunk;
        last CHUNKER;
      }
    }
    $submissions = $remaining_submissions;
    $remaining_submissions = [];
    $num_submissions = scalar(@$submissions);
  }
  debug("done");
}

sub flush {
  my $self = shift;
  my $num_submissions = $self->num_queued_submissions();
  if ($num_submissions == 0) {
    return;
  }
  my $err;
  my $dbh = $self->dbh;
  $dbh->begin_work() or die($dbh->errstr);
  try {
    $self->_insert_submissions($self->queued_submissions());

    $self->clear_queued_submissions();
    $dbh->commit();
  } catch {
    $err = shift;
    $dbh->rollback();
  };
  my $delta = tv_interval($self->last_flush);
  $self->last_flush([gettimeofday]);
  if ($err) {
    die($err);
  }
  my $rate = $num_submissions  / $delta;
  debug("Events per second: $rate");
}

__PACKAGE__->meta->make_immutable();

1;

