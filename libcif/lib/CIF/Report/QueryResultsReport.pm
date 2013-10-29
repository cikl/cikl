package CIF::Report::QueryResultsReport;
use parent 'CIF::Report::ReportInterface';

use strict;
use warnings;

use constant HEADER_ROW => qw(
restriction guid assessment description confidence detecttime reporttime
address alternativeid_restriction alternativeid
);

sub new {
  my $class = shift;
  my $query_results = shift;

  my $self = $class->SUPER::new();

  $self->{query_results} = $query_results;

  return $self;
}

sub event_fields {
  my $self = shift;
  my @header = HEADER_ROW;
  return \@header;
}

sub _generate_row {
  my $self = shift;
  my $event = shift;
  my $ret = {};
  foreach my $key (HEADER_ROW) {
    $ret->{$key} = $event->{$key};
  }
  return $ret;
}

sub body_iterator {
  my $self = shift;
  my $event_count = $self->{query_results}->event_count();
  my $events = $self->{query_results}->events();
  my $num = -1;

  return sub {
    $num += 1;
    if ($num > $event_count) {
      return undef;
    }

    my $ret = $self->_generate_row($events->[$num]);
    my $pretty_guid = $self->{query_results}->get_pretty_group_name($ret->{guid});
    if ($pretty_guid) {
      $ret->{guid} = $pretty_guid;
    }
    return $ret;
  };
}

1;
