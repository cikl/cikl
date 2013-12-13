package CIF::Postgres::SQL;
use strict;
use warnings;
use Try::Tiny;
use Mouse;
use CIF qw/debug/;
require CIF::Postgres::UserInfo;
use List::MoreUtils qw/natatime/;
use namespace::autoclean;
use Time::HiRes qw/tv_interval gettimeofday/;
require SQL::Abstract::More;

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


use constant SQL_GET_GROUP_ID_MAPPING => q{
SELECT id FROM cif_group WHERE name = ?;
};

use constant SQL_GET_APIKEY_INFO => q{
SELECT * from cif_users WHERE apikey = ?;
};


use constant SQL_GET_USER_INFO => q{
SELECT
  u.id
  ,u.apikey
  ,u.name
  ,u.revoked
  ,u.write
  ,u.created
  ,u.expires
  ,ug.name as "default_group_name"
  ,(
      SELECT 
        ARRAY_AGG(g.name) 
      FROM 
        cif_user_group_map as m 
        INNER JOIN cif_group as g 
          ON (m.group_id = g.id) 
      WHERE 
        m.user_id = u.id
    ) as "additional_groups"
FROM 
  cif_user AS u 
  INNER JOIN cif_group as ug
    ON (u.default_group_id = ug.id)
WHERE 
  u.apikey = ?;
};



use constant SQL_GET_APIKEY_GROUPS => q{
SELECT g.id,g.name 
FROM 
  cif_groups g 
  INNER JOIN cif_user_group_map m 
    ON (g.id = m.group_id) 
WHERE m.user_id = ?;
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
  return "INSERT INTO archive (data,group_id,created,reporttime,assessment,confidence,asn,cidr,email,fqdn,url) VALUES " . 
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

has 'get_group_id_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_GET_GROUP_ID_MAPPING) }
);

has 'get_user_info_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_GET_USER_INFO) }
);

has 'get_apikey_groups_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_GET_APIKEY_GROUPS) }
);

has '_group_id_cache' => (
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

sub get_group_id {
  my $self = shift;
  my $group = lc(shift);

  if (my $existing = $self->_group_id_cache->{$group}) {
    return $existing;
  }

  my $sth = $self->get_group_id_sth;
  if (!$sth->execute($group)) {
    die("Failed to get group mapping!: " . $self->dbh->errstr);
  }
  my $id = undef;
  if (my $data = $sth->fetchrow_hashref()) {
    $sth->finish();
    $id = $data->{id};
    $self->_group_id_cache->{$group} = $id;
  }
  return $id;
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
    my ($group_id, $event, $event_json) = @$value_ref;
    my $addresses = {};
    foreach my $address (@{$event->addresses()}) {
      my $index = INDEX_TYPE_MAP->{$address->type()} 
          or die("Unknown type: " . $address->type());
      my $x = ($addresses->{$index} ||= []);
      push(@$x, $address->value());
    }
    push(@values, 
      $event_json, 
      $group_id, 
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
    if (!defined($chunk_size)) {
      die("Undefined chunk size!");
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
  if ($num_events == 0) {
    return;
  }
  my $err;
  my $dbh = $self->dbh;
  $dbh->begin_work() or die($dbh->errstr);
  try {
    $self->_insert_events($self->queued_events());
    $self->clear_queued_events();
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
    user_info => $ret
  };
  return $ret;
};

sub get_user_info {
  my $self = shift;
  my $apikey = shift;
  my $sth = $self->get_user_info_sth;
  $sth->execute($apikey) or die($self->dbh->errstr);
  my $user_info = $sth->fetchrow_hashref();
  $sth->finish();
  return $user_info;
}

sub key_retrieve {
  my $self = shift;
  my $apikey = shift;
  if (my $cache_info = $self->_auth_cache->{lc($apikey)}) {
    if ($cache_info->{expire} > time()) {
      return $cache_info->{user_info};
    }
    undef $self->_auth_cache->{lc($apikey)};
  }

  my $user_info_row = $self->get_user_info($apikey);
  if (!$user_info_row) {
    debug("could not find $apikey");
    return $self->_store_auth_in_cache($apikey, undef);
  }

  my $user_info = CIF::Postgres::UserInfo->from_db($user_info_row);
  return ($self->_store_auth_in_cache($apikey, $user_info));
}

sub _add_range {
  my $arrayref = shift;
  my $fieldname = shift;
  my $range = shift;
  
  if (defined($range->min())) {
    push(@$arrayref, {$fieldname => {">=" => $range->min()}});
  }
  if (defined($range->max())) {
    push(@$arrayref, {$fieldname => {">=" => $range->max()}});
  }
}

sub _sql_array_contains {
  my ($self, $field, $op, $arg) = @_;
  my $label         = $self->_quote($field);
  my $placeholder = $self->_convert('?');
  my $sql           = "$label <@ $placeholder";
  my @bind = $self->_bindtype($field, [$arg]);
  return ($sql, @bind);
}

sub _sql_overlaps_cidr {
  my $self = shift;
  my $field = shift;
  my $op = shift;
  my $cidr = shift;

  my $label = $self->_quote($field);
  my $placeholder = $self->_convert('?');
  my $sql = "${placeholder}::cidr >>= ANY($label)" . 
    " OR ${placeholder}::cidr <<= ANY($label)";
  my @bind = $self->_bindtype($field, $cidr, $cidr);
  return ($sql, @bind);
}

use constant SQL_ABSTRACT_SPECIAL_OPS => [
  { regex => qr/^array_contains$/, handler => \&_sql_array_contains },
  { regex => qr/^overlaps_cidr$/, handler => \&_sql_overlaps_cidr }
];

sub search {
  my $self = shift;
  my $query = shift;

  my $group_id = $self->get_group_id($query->group);
  if (!defined($group_id)) {
    debug("unknown group" . $query->group);
    return [];
  }

  my $sql = SQL::Abstract::More->new(
    special_ops => SQL_ABSTRACT_SPECIAL_OPS
  );


  my @and;
  push(@and, { group_id => $group_id});

  my @address_criteria;

  if ($query->confidence) {
    _add_range(\@and, "confidence", $query->confidence);
  }
  if ($query->reporttime) {
    _add_range(\@and, "reporttime", $query->reporttime);
  }
  if ($query->detecttime) {
    _add_range(\@and, "created", $query->detecttime);
  }

  my @asns;
  my @emails;
  my @fqdns;
  my @urls;

  foreach my $op (@{$query->address_criteria}) {
    my $operator = $op->operator;
    if ($operator eq 'asn') {
      push(@asns, $op->value());
    } elsif ($operator eq 'email') {
      push(@emails, $op->value());
    } elsif ($operator eq 'fqdn') {
      push(@fqdns, $op->value());
    } elsif ($operator eq 'url') {
      push(@urls, $op->value());
    } elsif ($operator eq 'ip') {
      push(@address_criteria, {cidr => {-overlaps_cidr => $op->value()}});
    } else {
      die("unknown operator: " . $operator);
    }
  }

  if (@asns >= 1) {
    push(@address_criteria, {asn => {-array_contains => \@asns}});
  }
  if (@emails >= 1) {
    push(@address_criteria, {email => {-array_contains => \@emails}});
  }
  if (@fqdns >= 1) {
    push(@address_criteria, {fqdn => {-array_contains => \@fqdns}});
  }
  if (@urls>= 1) {
    push(@address_criteria, {url=> {-array_contains => \@urls}});
  }

  if (scalar(@address_criteria)) {
    push(@and, {-or => \@address_criteria});
  }

  my ($stmt, @bind) = $sql->select(
    -columns => ['data'],
    -from => 'archive',
    -where => {-and => \@and},

    # TODO add limit handling. Don't want to pull the whole DB.
    -limit => $query->limit, 
    -order_by => [ '-reporttime' ],
  );

  debug("Generated query SQL: $stmt");

  my $sth = $self->dbh->prepare_cached($stmt) or die ($self->dbh->errstr);

  $sth->execute(@bind) or die($self->dbh->errstr);

  my $event_json = $sth->fetchall_arrayref();
  # It's the first column of each row, so we map it down.
  $event_json =  [ map {$_->[0]} @$event_json ];
  return $event_json;

}


__PACKAGE__->meta->make_immutable();

1;
