package CIF::Smrt::Parser;

use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF::Models::Event;


sub new {
  my $class = shift;
  my $config = shift;
  my $self = {
    config => $config
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
  my $ret = CIF::Models::Event->new();
  map { $ret->{$_} = $self->config->{$_} } keys %{$self->config};
  return $ret;
}

1;
