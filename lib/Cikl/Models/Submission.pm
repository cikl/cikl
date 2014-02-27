package Cikl::Models::Submission;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use Cikl::Models::Event;
use Mouse;
use Cikl::DataTypes;
use namespace::autoclean;
use JSON;

our $JSON = JSON->new()->utf8(1);

has 'apikey' => (
  is => 'rw',
  isa => 'Cikl::DataTypes::LowercaseUUID',
  required => 1
);

# Set this after the submission has been inserted.
has 'datastore_id' => (
  is => 'rw',
  isa => 'Any',
  predicate => 'has_datastore_id',
  required => 0
);

has 'event' => (
  is => 'rw',
  isa => 'Cikl::Models::Event',
  required => 0,
  lazy => 1,
  builder => '_build_event'
);

has 'event_json' => (
  is => 'rw',
  isa => 'Str',
  required => 0,
  lazy => 1,
  builder => '_build_event_json'
);

sub _build_event {
  Cikl::Models::Event->from_hash($JSON->decode($_[0]->event_json));
}

sub _build_event_json {
  $JSON->encode($_[0]->event()->to_hash);
}

sub BUILD {
  if (!exists($_[0]->{event}) && !exists($_[0]->{event_json})) {
    die("at least event OR event_json must be provided");
  }
}

sub to_hash {
  return {
    apikey => $_[0]->apikey,
    event_json => $_[0]->event_json()
  };
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  if ($data->{event}) {
    $data->{event} = Cikl::Models::Event->from_hash($data->{event});
  }
  return $class->new($data);
}

__PACKAGE__->meta->make_immutable();
1;

