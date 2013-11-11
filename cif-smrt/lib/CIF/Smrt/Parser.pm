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

sub create_event {
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
