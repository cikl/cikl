package CIF::Models::QueryResults;
use strict;
use warnings;
use CIF::Models::Event;
use CIF::Models::Query;
use CIF::DataTypes;
use Mouse;
use namespace::autoclean;

use constant MANDATORY_FIELDS => qw/query events/;

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

has 'group' => (
  is => 'ro',
  isa => 'CIF::DataTypes::LowerCaseStr',
  lazy => 1,
  default => sub { my $self = shift; $self->query->group() }
);

sub event_count { $#{$_[0]->events}; };
sub query_limit { $_[0]->query->limit(); };

sub to_hash {
  my $self = shift;
  my @events = map { $_->to_hash() } @{$self->events};
  my $ret = {
    query => $self->query()->to_hash(),
    events => \@events,
    reporttime => $self->reporttime,
    group => $self->group,
  };

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
