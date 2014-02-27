package Cikl::Postgres::AuthSQL;
use strict;
use warnings;
use Try::Tiny;
use Mouse;
use Cikl qw/debug/;
require Cikl::Postgres::UserInfo;
use List::MoreUtils qw/natatime/;
use namespace::autoclean;
use Time::HiRes qw/tv_interval gettimeofday/;
require SQL::Abstract::More;

use constant SQL_GET_GROUP_ID_MAPPING => q{
SELECT id FROM cikl_group WHERE name = ?;
};

use constant SQL_GET_APIKEY_INFO => q{
SELECT * from cikl_users WHERE apikey = ?;
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
        cikl_user_group_map as m 
        INNER JOIN cikl_group as g 
          ON (m.group_id = g.id) 
      WHERE 
        m.user_id = u.id
    ) as "additional_groups"
FROM 
  cikl_user AS u 
  INNER JOIN cikl_group as ug
    ON (u.default_group_id = ug.id)
WHERE 
  u.apikey = ?;
};

use constant SQL_GET_APIKEY_GROUPS => q{
SELECT g.id,g.name 
FROM 
  cikl_groups g 
  INNER JOIN cikl_user_group_map m 
    ON (g.id = m.group_id) 
WHERE m.user_id = ?;
};

has 'dbh' => (
  is => 'ro',
  isa => 'DBI::db',
  required => 1
);

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
  $self->dbh->disconnect();
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

  my $user_info = Cikl::Postgres::UserInfo->from_db($user_info_row);
  return ($self->_store_auth_in_cache($apikey, $user_info));
}

__PACKAGE__->meta->make_immutable();

1;

