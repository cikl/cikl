package CIF::Models::Submission;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF::Models::Event;

sub new {
  my $class = shift;
  my $self = {};
  $self->{apikey} = shift;
  $self->{guid} = shift;
  $self->{event} = shift;
  bless $self, $class;
  return $self;
}

sub apikey { $_[0]->{apikey} };
sub guid { $_[0]->{guid} };
sub event { $_[0]->{event} };

sub to_hash {
  my $self = shift;
  my $data = {
    apikey => $self->apikey,
    guid => $self->guid,
    event => $self->event->to_hash()
  };
  return $data;
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  my $event = CIF::Models::Event->from_hash($data->{event});
  return $class->new(
    $data->{apikey},
    $data->{guid},
    $event
  );
}

1;

