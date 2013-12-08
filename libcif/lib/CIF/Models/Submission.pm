package CIF::Models::Submission;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF::Models::Event;
use Moose;
use CIF::DataTypes;
use namespace::autoclean;

has 'apikey' => (
  is => 'rw',
  isa => 'CIF::DataTypes::LowercaseUUID',
  required => 1
);

has 'event' => (
  is => 'rw',
  isa => 'CIF::Models::Event',
  required => 1
);

sub to_hash {
  my $self = shift;
  my $data = {
    apikey => $self->apikey,
    event => $self->event->to_hash()
  };
  return $data;
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  my $event = CIF::Models::Event->from_hash($data->{event});
  return $class->new(
    apikey => $data->{apikey},
    event => $event
  );
}

__PACKAGE__->meta->make_immutable();
1;

