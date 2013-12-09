package CIF::ArchiveDataStore;
use strict;
use warnings;
use Mouse;
use namespace::autoclean;
use CIF::DataStore;
use Try::Tiny;
require CIF::APIKey;
require CIF::APIKeyGroups;
require CIF::APIKeyRestrictions;
use CIF::Archive;
use CIF::Archive::Flusher;
use CIF qw/debug is_uuid generate_uuid_ns/;
with "CIF::DataStore";

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

has 'group_map' => (
  is => 'ro',
  isa => 'ArrayRef',
  required => 1
);

has 'restriction_map' => (
  is => 'ro',
  isa => 'ArrayRef',
  required => 1
);

has 'flusher' => (
  is => 'rw',
  isa => 'Maybe[CIF::Archive::Flusher]',
  required => 0
);

has '_auth_write_cache' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default => sub { {} }
);

has '_auth_cache' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default => sub { {} }
);


sub BUILD {
  my $self = shift;
  $self->_init_dbi();
}

sub _init_dbi {
  my $self = shift;
  my $dbi = 'DBI:Pg:database='.$self->database.';host='.$self->host;
  my $ret = CIF::DBI->connection($dbi,$self->user,$self->password,{ AutoCommit => 0});
  debug("ret: " . $ret);
}

sub submit { 
  my $self = shift;
  my $submission = shift;
  $self->insert_event($submission->event);
}

sub insert_event {
  my $self = shift;
  my $event = shift;
  $self->flusher->tick() if ($self->flusher);
  CIF::Archive->insert($event);
}

sub search {
  my $self = shift;
  my $query = shift;
  CIF::Archive->search($query);
}

sub flush {
  my $self = shift;
  CIF::Archive->dbi_commit();
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

  my ($keyinfo,$err);
  try {
    my $rec = CIF::APIKey->retrieve(uuid => $apikey);
    $keyinfo = CIF::ArchiveDataStore::ApikeyInfo->from_apikey($rec);
    $self->_auth_cache->{lc($apikey)} = {
      expire => time() + 60,
      apikey_info => $keyinfo
    };
  } catch {
    $err = shift;
  };
  return(0) if($err);
  return($keyinfo);
}

sub authorized_write {
  my $self = shift;
  my $apikey = shift;
  my $guid = shift;

  my $rec = $self->key_retrieve($apikey);
  return (defined($rec) && $rec->can_write() && $rec->in_group($guid));
}


sub authorized_read {
    my $self = shift;
    my $key = shift;
    my $guid = shift;
    
    my $rec = $self->key_retrieve($key);
    die('invaild/expired apikey') unless($rec);
    if (!defined($guid)) {
      $guid = $rec->default_guid;
    }

    if (!$rec->in_group($guid)) {
      die("not authorized for supplied guid");
    }
    
    my $ret = {
      default_guid => $rec->default_guid()
    };
    
    ## TODO -- datatype access control?
    
    my @groups = ($self->group_map) ? @{$self->group_map()} : undef;
   
    my @array;
    #debug('groups: '.join(',',map { $_->get_key() } @groups));
    
    foreach my $g (@groups){
        next unless($rec->in_group($g->{key}));
        push(@array,$g);
    }

    $ret->{'group_map'} = \@array;
    
    if(my $m = $self->restriction_map()){
        $ret->{'restriction_map'} = $m;
    }

    return $ret; # all good
}

__PACKAGE__->meta->make_immutable();


sub new_from_config {
  my $class = shift;
  my $config = shift;
  my $db_config = $config->param(-block => 'db');
  my $archive_config = $config->param(-block => 'archive');

  my $groups = $archive_config->{'groups'};

  # system wide groups
  push(@$groups, qw(everyone root));
  my $group_map;
  foreach (@$groups){
    my $m = {
      key     => generate_uuid_ns($_),
      value   => $_,
    };
    push(@$group_map,$m);
  }

  my $restriction_map_conf = $config->param(-block => 'restriction_map');
  my $restriction_map = [];
  foreach (keys %{$restriction_map_conf}){
    ## TODO map to the correct Protobuf RestrictionType
    my $m = {
      key => $_,
      value   => $restriction_map_conf->{$_},
    };
    push(@$restriction_map,$m);
  }

  my $datastore = CIF::ArchiveDataStore->new(
    database => $db_config->{database} || 'cif',
    user => $db_config->{user} || 'cif',
    password => $db_config->{password} || '',
    host => $db_config->{host} || 'localhost',
    group_map => $group_map,
    restriction_map => $restriction_map
  );

  return $datastore;
}

sub shutdown {
  my $self = shift;
  debug("Shutting down");
  if ($self->flusher()) {
    $self->flusher()->flush();
    $self->flusher(undef);
  }
  $self->flush();
}

package CIF::ArchiveDataStore::ApikeyInfo;
use strict;
use warnings;
use Mouse;
use namespace::autoclean;

has 'uuid' => (
  is => 'ro',
  required => 1
);

has 'default_guid' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'revoked' => (
  is => 'ro',
  isa => 'Bool',
  default => 0
);

has 'write' => (
  is => 'ro',
  isa => 'Bool',
  default => 0
);

has 'restricted_access' => (
  is => 'ro',
  isa => 'Bool',
  default => 0
);

has 'expires' => (
  is => 'ro',
  isa => 'Maybe[Int]'  # Epoch
);

has 'groups' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { {} }
);

sub in_group {
  return $_[0]->groups->{$_[1]};
}

sub is_expired {
  return (defined($_[0]->expires) && $_[0]->expires > time());
}

sub in_good_standing {
  return (
    ! $_[0]->restricted_access()
    && ! $_[0]->revoked()
    && ! $_[0]->is_expired()
  );
}

sub can_write {
  return ($_[0]->write && $_[0]->in_good_standing());
}

sub can_read {
  my $self = shift;
  return ($_[0]->in_good_standing());
}

sub from_apikey {
  my $class = shift;
  my $apikey_obj = shift;

  my $args = {
    uuid => $apikey_obj->uuid,
    revoked => $apikey_obj->revoked || 0,
    write => $apikey_obj->write || 0,
    restricted_access => $apikey_obj->restricted_access || 0,
    groups => {}
  };

  if ($apikey_obj->expires()) {
    $args->{expires} = DateTime::Format::DateParse->parse_datetime($apikey_obj->expires())->epoch();
  }

  foreach my $group ($apikey_obj->groups) {
    if ($group->default_guid()) {
      $args->{default_guid} = $group->guid();
    }
    $args->{groups}->{$group->guid()} = 1;
  }

  return $class->new(%$args);

}

__PACKAGE__->meta->make_immutable();

1;


