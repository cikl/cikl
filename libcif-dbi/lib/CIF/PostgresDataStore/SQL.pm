package CIF::PostgresDataStore::SQL;
use strict;
use warnings;
use Try::Tiny;
use Mouse;
use CIF qw/debug is_uuid generate_uuid_ns/;
use CIF::PostgresDataStore::ApikeyInfo;
use SQL::Abstract;
use CIF::Codecs::JSON;
use List::MoreUtils qw/natatime/;
use namespace::autoclean;

use constant SQL_GET_GUID_ID_MAPPING => q{
SELECT id FROM archive_guid_map WHERE guid = ? LIMIT 1;
};

use constant SQL_CREATE_GUID_MAP => q{
LOCK TABLE archive_guid_map IN ACCESS EXCLUSIVE MODE;
INSERT INTO archive_guid_map (guid) 
SELECT $1 WHERE NOT EXISTS (SELECT 1 FROM archive_guid_map WHERE guid = $1);
};

use constant SQL_INSERT_EVENT => q{
INSERT INTO archive (data,guid_id,created,reporttime)
VALUES (?, ?, to_timestamp(?), to_timestamp(?)) RETURNING id
};

use constant SQL_GET_APIKEY_INFO => q{
SELECT * from apikeys WHERE uuid = ?;
};

use constant SQL_GET_APIKEY_GROUPS => q{
SELECT * from apikeys_groups WHERE uuid = ?;
};

has 'dbh' => (
  is => 'ro',
  isa => 'DBI::db',
  required => 1
);

has '_db_codec' => (
  is => 'ro', 
  init_arg => undef,
  default => sub {CIF::Codecs::JSON->new()}
);


has 'insert_event_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_INSERT_EVENT) }
);

sub build_insert_event_sql {
  my $count = shift;
  my @values;
  for (my $i = 0; $i < $count; $i++) {
    push(@values, "(?,?,to_timestamp(?),to_timestamp(?))");
  }
  return "INSERT INTO archive (data,guid_id,created,reporttime) VALUES " . 
    join(", ", @values) .
    " RETURNING id;";
}

has 'insert_event_500_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { 
    $_[0]->dbh->prepare(build_insert_event_sql(500)) ;
  }
);

has 'insert_event_100_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { 
    $_[0]->dbh->prepare(build_insert_event_sql(100)) ;
  }
);

has 'insert_event_1000_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { 
    $_[0]->dbh->prepare(build_insert_event_sql(1000)) ;
  }
);

has 'insert_event_2000_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { 
    $_[0]->dbh->prepare(build_insert_event_sql(2000)) ;
  }
);

has "queued_events" => (
  traits => ['Array'],
  is => 'ro',
  isa => 'ArrayRef',
  default => sub {[]},
  handles => {
    _push_event_data => 'push',
    num_queued_events => 'count',
    clear_queued_events => 'clear'
  }
);

sub queue_event {
  my $self = shift;
  my $guid_id = shift;
  my $event = shift;
  $self->_push_event_data([
      $guid_id, $event
    ]);
}

has 'get_guid_id_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_GET_GUID_ID_MAPPING) }
);

has 'create_guid_map_if_not_exists_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_CREATE_GUID_MAP) }
);

has 'get_apikey_info_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_GET_APIKEY_INFO) }
);

has 'get_apikey_groups_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_GET_APIKEY_GROUPS) }
);

has '_guid_id_cache' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default => sub { {} }
);


has 'indexer_map' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  lazy => 1,
  builder => '_build_indexer_map'
);

sub index_address {
  my $indexer = $_[0]->indexer_map->{$_[2]->type};
  return undef unless ($indexer);
  $indexer->($_[1], $_[2]->value);
}

sub _build_indexer {
  my $self = shift;
  my $column = shift;
  my $sql = SQL::Abstract->new();
  my $stmt = $sql->insert("archive_lookup", {
      id => 1,
      $column => 1
    });
  my $sth = $self->dbh->prepare($stmt);
  return sub {
    $sth->execute($sql->values({id => $_[0], $column => $_[1]}));
  };
}

sub _build_indexer_map {
  my $self = shift;
  my $ret = {};
  $ret->{asn} = $self->_build_indexer("asn");
  $ret->{email} = $self->_build_indexer("email");
  $ret->{fqdn} = $self->_build_indexer("fqdn");
  $ret->{ipv4} = $self->_build_indexer("cidr");
  $ret->{ipv4_cidr} = $self->_build_indexer("cidr");
  $ret->{url} = $self->_build_indexer("url");
  $ret;
}

sub insert_event_old {
  my $self = shift;
  my ($data, $guid_id, $created, $reporttime) = @_;
  my $sth = $self->insert_event_sth;
  $sth->execute($data, $guid_id, $created, $reporttime) or die($self->dbh->errstr);
  my $id = $sth->fetchrow_hashref->{'id'};
  $sth->finish();
  return $id;
}

sub get_guid_id {
  my $self = shift;
  my $guid = lc(shift);
  if (my $existing = $self->_guid_id_cache->{$guid}) {
    return $existing;
  }
  my $dbh = $self->dbh;
  my $sth = $self->create_guid_map_if_not_exists_sth;;

  try {
    $sth->execute($guid) or die ($dbh->errstr);
    $dbh->commit();
  } catch {
    $dbh->rollback();
  };

  $sth = $self->get_guid_id_sth;
  if (!$sth->execute($guid)) {
    die("Failed to get guid mapping!: " . $dbh->errstr);
  }
  if (my $data = $sth->fetchrow_hashref()) {
    $sth->finish();
    my $id = $data->{id};
    $self->_guid_id_cache->{$guid} = $id;
    return $id;
  }
  $sth->finish();
  die("Failed to get guid mapping!");
}

sub shutdown {
  my $self = shift;
  $self->flush();
  $self->dbh->disconnect();
}

sub do_insert_events {
  my $self = shift;
  my $sth = shift;
  my $events = shift;
  my $codec = $self->_db_codec();
  my @values;
  foreach my $value_ref (@$events) {
    #my ($data, $guid_id, $created, $reporttime) = @_;
    my ($guid_id, $event) = @$value_ref;
    push(@values, $codec->encode_event($event), $guid_id, $event->detecttime, $event->reporttime);
  }
  $sth->execute(@values) or die($self->dbh->errstr);
  my $ids = $sth->fetchall_arrayref();
  $sth->finish(); # TODO read the return;
  return $ids;
}

sub _insert_events {
  my $self = shift;
  my $events = shift;
  my $sth;
  my $chunk_size;
  my $it;
  my $num_events = scalar(@$events);
  my $remaining_events = [];

  while ($num_events > 0) {
    if ($num_events >= 1000) {
      $chunk_size = 1000;
      $sth = $self->insert_event_1000_sth;
    } elsif ($num_events >= 500) {
      $chunk_size = 500;
      $sth = $self->insert_event_500_sth;
    } elsif ($num_events >= 100) {
      $chunk_size = 100;
      $sth = $self->insert_event_100_sth;
    } else {
      $chunk_size = 1;
      $sth = $self->insert_event_sth;
    }
    $it = natatime($chunk_size, @$events);
    CHUNKER: while (my @chunk = $it->()) {
      my $x = scalar(@chunk);
      if ($x == $chunk_size) {
        my $ids = $self->do_insert_events($sth, \@chunk);
      } else {
        $remaining_events = \@chunk;
        last CHUNKER;
      }
    }
    $events = $remaining_events;
    $remaining_events = [];
    $num_events = scalar(@$events);
  }
  debug("done");
}

sub flush {
  my $self = shift;
  $self->_insert_events($self->queued_events());
  $self->clear_queued_events();
  $self->dbh->commit();
}


has '_auth_cache' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default => sub { {} }
);

sub _store_auth_in_cache {
  my $self = shift;
  my $apikey = shift;
  my $ret = shift;
  $self->_auth_cache->{lc($apikey)} = {
    expire => time() + 60,
    apikey_info => $ret
  };
  return $ret;
};

sub get_apikey_info {
  my $self = shift;
  my $apikey = shift;
  my $sth = $self->get_apikey_info_sth;
  $sth->execute($apikey) or die($self->dbh->errstr);
  my $apikey_info = $sth->fetchrow_hashref();
  $sth->finish();
  return $apikey_info;
}

sub get_apikey_groups {
  my $self = shift;
  my $apikey = shift;
  my $sth = $self->get_apikey_groups_sth;
  $sth->execute($apikey) or die($self->dbh->errstr);
  my $apikey_groups = $sth->fetchall_hashref('guid');
  $sth->finish();
  if (!scalar(keys(%$apikey_groups))) {
    return undef;
  }
  return $apikey_groups;
}

sub key_retrieve {
  my $self = shift;
  my $apikey = shift;
  if (my $cache_info = $self->_auth_cache->{lc($apikey)}) {
    if ($cache_info->{expire} > time()) {
      return $cache_info->{apikey_info};
    }
    undef $self->_auth_cache->{lc($apikey)};
  }

  my $apikey_info = $self->get_apikey_info($apikey);
  if (!$apikey_info) {
    return $self->_store_auth_in_cache($apikey, undef);
  }

  my $apikey_groups = $self->get_apikey_groups($apikey);;
  if (!$apikey_groups) {
    return $self->_store_auth_in_cache($apikey, undef);
  }

  my $auth_obj = CIF::PostgresDataStore::ApikeyInfo->from_db($apikey_info, $apikey_groups);
  return ($self->_store_auth_in_cache($apikey, $auth_obj));
}


__PACKAGE__->meta->make_immutable();

1;
