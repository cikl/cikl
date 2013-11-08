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
  my $self = {
    config => $config,
    default_event_data => $config->default_event_data()
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

  my $ret = CIF::Models::Event->new($merged_hash);
  return $ret;
}

1;
