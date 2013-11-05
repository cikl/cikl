package CIF::Smrt::Broker;
use strict;
use warnings;


sub new {
  my $class = shift;
  my $self = {};

  bless $self, $class;
  $self->{data} = [];
  return($self);
}

sub emit {
  my $self = shift;
  my $event = shift;
  push(@{$self->{data}}, $event);
}

sub data {
  my $self = shift;
  return($self->{data});
}

1;
