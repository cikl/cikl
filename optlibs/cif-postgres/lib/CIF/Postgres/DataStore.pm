package CIF::Postgres::DataStore;
use strict;
use warnings;
use Mouse;
use CIF qw/debug is_uuid generate_uuid_ns/;
use CIF::DataStore ();
use CIF::Codecs::JSON ();
use DBI ();
use CIF::Postgres::SQL ();
use CIF::DataStore::Flusher ();
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

has '_db_codec' => (
  is => 'ro', 
  init_arg => undef,
  default => sub {CIF::Codecs::JSON->new()}
);

has 'sql' => (
  is => 'ro',
  isa => 'CIF::Postgres::SQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_sql'
);

sub _build_sql {
  my $self = shift;
  my $connect_str = 'DBI:Pg:database='. $self->database.';host='.$self->host;
  my $dbh = DBI->connect($connect_str,$self->user,$self->password, {AutoCommit => 1});
  if (!$dbh) {
    die($!);
  }
  my $sql = CIF::Postgres::SQL->new(dbh => $dbh);

  $self->flusher->set_datastore_flush_coderef(
    sub {
      $self->sql->flush();
    }
  );
  return $sql;
}

sub submit { 
  my $self = shift;
  my $submission = shift;
  my $group_id = $self->sql->get_group_id($submission->event->group);
  if (!defined($group_id)) {
    die("Failed to create/retreive group ID for: " . $submission->event->group);
  }
  $self->sql->queue_event($group_id, $submission->event(), $submission->event_json());
  $self->flusher->tick();
  return (undef, 1);
}

sub search {
  my $self = shift;
  my $query = shift;
  my $arrayref_event_json = $self->sql->search($query);

  my $codec = $self->_db_codec;
  my $ret = [ map { $codec->decode_event($_); } @$arrayref_event_json ];
  return $ret;
}

sub authorized_write {
  my $self = shift;
  my $apikey = shift;
  my $group = shift;

  my $rec = $self->sql->key_retrieve($apikey);
  return (defined($rec) && $rec->can_write() && $rec->in_group($group));
}

sub authorized_read {
    my $self = shift;
    my $key = shift;
    my $group = shift;
    
    my $rec = $self->sql->key_retrieve($key);
    die('invaild/expired apikey') unless($rec);
    if (!defined($group)) {
      $group = $rec->default_group_name;
    }

    if (!$rec->in_group($group)) {
      die("not authorized for supplied group");
    }
    
    my $ret = {
      default_group => $rec->default_group_name()
    };

    return $ret; # all good
}

sub flush {
  my $self = shift;
  $self->sql->flush();
}

after "shutdown" => sub {
  my $self = shift;
  $self->sql->shutdown();
};

__PACKAGE__->meta->make_immutable();


1;
