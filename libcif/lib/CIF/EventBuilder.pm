package CIF::EventBuilder;
use strict;
use warnings;
use CIF::Models::Event;

sub new {
  my $class = shift;
  my $normalizer = shift;
  my $default_event_data = shift;
  my $self = {
    normalizer => $normalizer,
    default_event_data => $default_event_data
  };

  bless $self, $class;
  return $self;
}

sub build_event {
  my $self = shift;
  my $hashref = shift;
  if (!defined($hashref)) {
    die("create_event requires a hashref of arguments!");
  }
  my $merged_hash = {%{$self->{default_event_data}}, %$hashref};
  my $normalized = $self->{normalizer}->normalize($merged_hash);
  if (!defined($normalized)) {
    return undef;
  }

  my $ret = CIF::Models::Event->new($normalized);
  return $ret;
}

1;

