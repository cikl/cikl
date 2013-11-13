package CIF::Smrt::Broker;
use strict;
use warnings;


sub new {
  my $class = shift;
  my $emit_cb = shift;
  my $builder = shift;
  my $self = {
    emit_cb => $emit_cb,
    builder => $builder
  };

  bless $self, $class;
  $self->{data} = [];
  $self->{count} = 0;
  $self->{count_too_old} = 0;
  return($self);
}

sub emit {
  my $self = shift;
  my $event_hash = shift;
  my $event = $self->{builder}->build_event($event_hash);
  if (defined($event)) {
    $self->{count} += 1;
    $self->{emit_cb}->($event);
  } else {
    $self->{count_too_old} += 1;
    # It was too old.
  }
}

sub count {
  my $self = shift;
  return $self->{count};
}

sub count_too_old {
  my $self = shift;
  return $self->{count_too_old};
}

sub data {
  my $self = shift;
  return($self->{data});
}

1;
