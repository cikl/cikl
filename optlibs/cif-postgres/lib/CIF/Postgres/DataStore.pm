package CIF::Postgres::DataStore;
use strict;
use warnings;
use Mouse;
use CIF::DataStore::Role ();
use CIF::Postgres::SQLRole ();
use CIF::Codecs::JSON ();
use namespace::autoclean;

with "CIF::DataStore::Role", "CIF::Postgres::SQLRole";

has '_db_codec' => (
  is => 'ro', 
  init_arg => undef,
  default => sub {CIF::Codecs::JSON->new()}
);

sub BUILD {
  my $self = shift;
  $self->flusher->set_datastore_flush_coderef(
    sub {
      $self->sql->flush();
    }
  );
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
