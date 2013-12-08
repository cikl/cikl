package CIF::Models::QueryResults;
use strict;
use warnings;
use CIF::Models::Event;
use CIF::Models::Query;
use CIF::DataTypes;
use Mouse;
use namespace::autoclean;

use constant MANDATORY_FIELDS => qw/query events/;
use CIF qw/generate_uuid_random/;

has 'query' => (
  is => 'ro',
  isa => 'CIF::Models::Query',
  required => 1
);

has 'events' => (
  is => 'ro',
  isa => 'ArrayRef[CIF::Models::Event]',
  required => 1
);

has 'reporttime' => (
  is => 'ro', 
  isa => 'Int',
  default => sub { time() }
);

has 'group_map' => (
  is => 'ro',
  isa => 'ArrayRef',
  required => 1
);

has 'restriction_map' => (
  is => 'ro',
  #isa => 'HashRef'
);

has 'guid' => (
  is => 'ro',
  isa => 'CIF::DataTypes::LowercaseUUID',
  lazy => 1,
  default => sub { my $self = shift; $self->query->guid() }
);

has 'uuid' => (
  is => 'ro',
  isa => 'CIF::DataTypes::LowercaseUUID',
  default => sub { generate_uuid_random() }
);

sub event_count { $#{$_[0]->events}; };
sub query_limit { $_[0]->query->limit(); };

sub get_pretty_group_name {
  my $self = shift;
  my $guid = shift;
  foreach my $x (@{$self->group_map()}) {
    if ($guid eq $x->{key}) {
      return $x->{value};
    }
  }
  return undef;
}

sub to_hash {
  my $self = shift;
  my @events = map { $_->to_hash() } @{$self->events};
  my @group_map = map { {value => $_->{value}, key => $_->{key}} } @{$self->group_map};
  my $ret = {
    query => $self->query()->to_hash(),
    events => \@events,
    reporttime => $self->reporttime,
    group_map => \@group_map,
    guid => $self->guid,
    uuid => $self->uuid
  };

  $ret->{restriction_map} =  $self->restriction_map if (defined($self->restriction_map));

  return $ret;
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

__PACKAGE__->meta->make_immutable();

1;
