package CIF::Models::QueryResults;
use strict;
use warnings;
use CIF::Models::Event;
use CIF::Models::Query;

use constant MANDATORY_FIELDS => qw/query events/;
use CIF qw/generate_uuid_random/;

sub new {
  my $class = shift;
  my $args = shift;
  my $self = {};

  for(MANDATORY_FIELDS) {
    die "Missing $_ parameter\n" unless exists($args->{$_});
  }

  $self->{query} = $args->{query};
  $self->{events} = $args->{events};
  $self->{reporttime} = $args->{reporttime} || time();
  $self->{group_map} = $args->{group_map};
  $self->{restriction_map} = $args->{restriction_map};
  $self->{guid} = $args->{guid} || $self->{query}->guid();
  $self->{uuid} = $args->{uuid} || generate_uuid_random();

  bless $self, $class;
  return $self;
}

sub query { $_[0]->{query}; };
sub events { $_[0]->{events}; };
sub reporttime { $_[0]->{reporttime}; };
sub group_map { $_[0]->{group_map}; };
sub restriction_map { $_[0]->{restriction_map}; };
sub guid { $_[0]->{guid}; };
sub uuid { $_[0]->{uuid}; };
sub query_limit { $_[0]->{query}->limit(); };

sub to_hash {
  my $self = shift;
  my @events = map { $_->to_hash() } @{$self->events};
  my @group_map = map { {value => $_->{value}, key => $_->{key}} } @{$self->group_map};
  return({
    query => $self->query()->to_hash(),
    events => \@events,
    reporttime => $self->reporttime,
    group_map => \@group_map,
    restriction_map => $self->restriction_map,
    guid => $self->guid,
    uuid => $self->uuid
  });
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  my @events = map { CIF::Models::Event->from_hash($_); } @{$data->{events}};
  my $query = CIF::Models::Query->from_hash($data->{query});
  $data->{query} = $query;
  $data->{events} = \@events;
  return $class->new($data);
}

1;
