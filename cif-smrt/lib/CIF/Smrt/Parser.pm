package CIF::Smrt::Parser;

use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF::Models::Event;

sub name {
  my $class = shift;
  die("$class has not implemented the name() method!");
}

sub new {
  my $class = shift;
  my $config = shift;
  my $normalizer = shift;
  my $self = {
    config => $config,
    default_event_data => $config->default_event_data(),
    normalizer => $normalizer
  };
  bless($self,$class);
  return($self);
}

sub config {
  my $self = shift;
  my $key = shift;
  return $self->{config};
}

sub parse {
  my $self = shift;

  return(blessed($self) . " has not implemented the parser() method!");
}

1;
