package Cikl::Models::QueryResults;
use strict;
use warnings;
use Cikl::Models::Event;
use Cikl::Models::Query;
use Cikl::DataTypes;
use Mouse;
use namespace::autoclean;

use constant MANDATORY_FIELDS => qw/query events/;

has 'query' => (
  is => 'ro',
  isa => 'Cikl::Models::Query',
  required => 1
);

has 'events' => (
  is => 'ro',
  isa => 'ArrayRef[Cikl::Models::Event]',
  required => 1
);

has 'reporttime' => (
  is => 'ro', 
  isa => 'Int',
  default => sub { time() }
);

has 'group' => (
  is => 'ro',
  isa => 'Cikl::DataTypes::LowerCaseStr',
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
  my @events = map { Cikl::Models::Event->from_hash($_); } @{$data->{events}};
  my $query = Cikl::Models::Query->from_hash($data->{query});
  $data->{query} = $query;
  $data->{events} = \@events;
  return $class->new($data);
}

__PACKAGE__->meta->make_immutable();

1;
