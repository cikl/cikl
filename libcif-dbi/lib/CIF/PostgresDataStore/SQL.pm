package CIF::PostgresDataStore::SQL;
use strict;
use warnings;
use Try::Tiny;
use Mouse;
use CIF qw/debug/;
require CIF::PostgresDataStore::ApikeyInfo;
use List::MoreUtils qw/natatime/;
use namespace::autoclean;
use Time::HiRes qw/tv_interval gettimeofday/;

use constant INDEX_SIZES => (2000, 1000, 500, 100, 1);
use constant LOOKUP_COLUMNS => qw(asn cidr email fqdn url);
use constant INDEX_TYPE_MAP => {
  asn => 'asn',
  email => 'email',
  fqdn => 'fqdn',
  ipv4 => 'cidr',
  ipv4_cidr => 'cidr',
  url => 'url'
};


use constant SQL_GET_GUID_ID_MAPPING => q{
SELECT id FROM archive_guid_map WHERE guid = ? LIMIT 1;
};

use constant SQL_CREATE_GUID_MAP => q{
LOCK TABLE archive_guid_map IN ACCESS EXCLUSIVE MODE;
INSERT INTO archive_guid_map (guid) 
SELECT $1 WHERE NOT EXISTS (SELECT 1 FROM archive_guid_map WHERE guid = $1);
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

has 'last_flush' => (
  is => 'rw',
  init_arg => undef,
  default => sub { [gettimeofday] } 
);

sub build_insert_event_sql {
  my $count = shift;
  my @values;
  for (my $i = 0; $i < $count; $i++) {
    push(@values, "(?,?,?,?,?,?,?,?,?,?,?)");
  }
  return "INSERT INTO archive (data,guid_id,created,reporttime,assessment,confidence,asn,cidr,email,fqdn,url) VALUES " . 
    join(",", @values) . ';';
}

has "queued_events" => (
  traits => ['Array'],
  is => 'ro',
  isa => 'ArrayRef',
  default => sub {[]},
  handles => {
    num_queued_events => 'count',
    clear_queued_events => 'clear'
  }
);

sub queue_event {
  my $self = shift;
  push(@{$self->queued_events}, \@_);
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


has 'inserter_sth_map' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  lazy => 1,
  builder => '_build_inserters'
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
  my @values;
  foreach my $value_ref (@$events) {
    my ($guid_id, $event, $event_json) = @$value_ref;
    my $addresses = {};
    foreach my $address (@{$event->addresses()}) {
      my $index = INDEX_TYPE_MAP->{$address->type()} 
          or die("Unknown type: " . $address->type());
      my $x = ($addresses->{$index} ||= []);
      push(@$x, $address->value());
    }
    push(@values, 
      $event_json, 
      $guid_id, 
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

sub _insert_events {
  my $self = shift;
  my $events = shift;
  my $sths = $self->inserter_sth_map;
  my $sth;
  my $chunk_size;
  my $it;
  my $num_events = scalar(@$events);
  my $remaining_events = [];

  while ($num_events > 0) {
    foreach my $sz (INDEX_SIZES) {
      if ($num_events > $sz) {
        $chunk_size = $sz;
        last;
      }
    }
    $sth = $sths->{$chunk_size} or die("Bad chunk size: $chunk_size");
    $it = natatime($chunk_size, @$events);
    CHUNKER: while (my @chunk = $it->()) {
      my $x = scalar(@chunk);
      if ($x == $chunk_size) {
        $self->do_insert_events($sth, \@chunk);
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
  my $num_events = $self->num_queued_events();
  $self->_insert_events($self->queued_events());
  $self->clear_queued_events();
  $self->dbh->commit();
  my $delta = tv_interval($self->last_flush);
  $self->last_flush([gettimeofday]);
  my $rate = $num_events  / $delta;
  debug("Events per second: $rate");
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
