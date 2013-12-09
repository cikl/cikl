package CIF::PostgresDataStore;
use strict;
use warnings;
use Mouse;
use CIF::DataStore;
use Try::Tiny;
use CIF::Codecs::JSON;
use DBI;
use CIF::PostgresDataStore::SQL;
use CIF::Archive::Flusher;
use CIF qw/debug is_uuid generate_uuid_ns/;
use namespace::autoclean;

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

has '_db_codec' => (
  is => 'ro', 
  init_arg => undef,
  default => sub {CIF::Codecs::JSON->new()}
);

has 'sql' => (
  is => 'ro',
  isa => 'CIF::PostgresDataStore::SQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_sql'
);

sub _build_sql {
  my $self = shift;
  my $connect_str = 'DBI:Pg:database='. $self->database.';host='.$self->host;
  my $dbh = DBI->connect($connect_str,$self->user,$self->password, {AutoCommit => 0});
  if (!$dbh) {
    die($!);
  }
  my $ret = CIF::PostgresDataStore::SQL->new(dbh => $dbh);
  return $ret;
}

sub insert_event {
  my $self = shift;
  my $event = shift;
  my $guid_id = $self->sql->get_guid_id($event->guid);
  $self->sql->queue_event($guid_id, $event);
  $self->flusher->tick() if ($self->flusher);
  return (undef, 1);
}

sub insert_event_old {
  my $self = shift;
  my $event = shift;
  my ($err, $ret);
  my $guid_id = $self->sql->get_guid_id($event->guid);
  my $id;
  try {
    $id = $self->sql->insert_event(
      $self->_db_codec->encode_event($event), 
      $guid_id, $event->detecttime, $event->reporttime);
  }
  catch {
    $err = shift;
  };
  die($err) if ($err);
  if (!$id) {
    die("Failed to get guid ID!");
  }
#  foreach my $address (@{$event->addresses()}) {
#    if (!$self->sql->index_address($id, $address)) {
#      debug("Unknown address type: " . $address->type);
#    }
#  }
  $self->flusher->tick() if ($self->flusher);
  return ($err) if($err);
  return (undef, $ret);
}

sub search {
  my $self = shift;
  my $query = shift;
  #TODO
}

sub flush {
  my $self = shift;
  $self->sql->flush();
}

sub authorized_write {
  my $self = shift;
  my $apikey = shift;
  my $guid = shift;

  my $rec = $self->sql->key_retrieve($apikey);
  return (defined($rec) && $rec->can_write() && $rec->in_group($guid));
}

sub authorized_read {
    my $self = shift;
    my $key = shift;
    my $guid = shift;
    
    my $rec = $self->sql->key_retrieve($key);
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

  my $datastore = CIF::PostgresDataStore->new(
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
  $self->sql->shutdown();
}

__PACKAGE__->meta->make_immutable();


1;
