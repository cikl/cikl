package CIF::ArchiveDataStore;
use strict;
use warnings;
use Moose;
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
  my ($rec,$err);
  try {
    $rec = CIF::APIKey->retrieve(uuid => $apikey);
  } catch {
    $err = shift;
  };
  return(0) if($err);
  return($rec);
}

sub authorized_write_cache_store {
    my $self = shift;
    my $key = shift;
    my $retval = shift;
    $self->_auth_write_cache->{$key} = {
      'time' => time(),
      'retval' => $retval
    };
    return $retval;
}

sub authorized_write_cache_get {
    my $self = shift;
    my $key = shift;

    if (my $cached_auth = $self->_auth_write_cache->{$key}) {
      if (time() - $cached_auth->{time} <= 60) {
        return $cached_auth->{retval};
      }
    }
    return undef;
}

sub authorized_write {
    my $self = shift;
    my $apikey = shift;

    my $retval = $self->authorized_write_cache_get($apikey);

    if (defined($retval)) {
      return($retval);
    }
    
    my $rec = $self->key_retrieve($apikey);

    my $ret;
    if (!defined($rec) || 
        !($rec->write()) ||
        $rec->revoked() || 
        $rec->restricted_access() ||
        $rec->expired() ) {
      $ret = 0;
    } else {
      $ret = {
        default_guid    => $rec->default_guid(),
      };
    }
    $self->authorized_write_cache_store($apikey, $ret);
    return($ret);
}


sub authorized_read {
    my $self = shift;
    my $key = shift;
    
    # test1
    die('invaild apikey') unless(is_uuid($key));
    
    my $rec = $self->key_retrieve($key);
    
    die('invaild apikey') unless($rec);
    die('apikey revokved') if($rec->revoked()); # revoked keys
    die('key expired') if($rec->expired());

    my $ret;
    my $args;
    my $guid = $args->{'guid'};
    if($guid){
        $guid = lc($guid);
        $ret->{'guid'} = generate_uuid_ns($guid) unless(is_uuid($guid));
    } else {
        $ret->{'default_guid'} = $rec->default_guid();
    }
    
    ## TODO -- datatype access control?
    
    my @groups = ($self->group_map) ? @{$self->group_map()} : undef;
   
    my @array;
    #debug('groups: '.join(',',map { $_->get_key() } @groups));
    
    foreach my $g (@groups){
        next unless($rec->inGroup($g->{key}));
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

1;


