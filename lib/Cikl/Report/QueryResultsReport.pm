package Cikl::Report::QueryResultsReport;
use parent 'Cikl::Report::ReportInterface';

use strict;
use warnings;

use constant HEADER_ROW => qw(
restriction group assessment description confidence detecttime reporttime
address alternativeid_restriction alternativeid
);

sub _format_text {
  my $text = shift;
  return $text;
}

sub _format_timestamp {
  my $unixtime = shift;
  my $t = DateTime->from_epoch(epoch => $unixtime);
  return($t->ymd().'T'.$t->hms().'Z');
}

sub _format_address{
  my $address = shift;
  if (!defined($address)) {
    return '';
  }
  return $address->value();
}

use constant FIELD_MAP => {
  detecttime => \&_format_timestamp,
  reporttime => \&_format_timestamp,
  address => \&_format_address,
};

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
    my $val = $event->$key;
    # If we have a formatter, format it !
    if (my $formatter = FIELD_MAP->{$key}) {
      $val = $formatter->($val);
    }
    $ret->{$key} = $val;
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
    return $ret;
  };
}

1;
