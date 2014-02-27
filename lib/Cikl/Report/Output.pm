package Cikl::Report::Output;

use strict;
use warnings;
use Scalar::Util qw(blessed);

sub new {
  my $class = shift;

  my $self = {};
  bless $self, $class;
  return $self;
}

sub write {
  my $self = shift;
  my $data = shift;

  die(blessed($self) . " has not implemented the write() method!");
}

sub close {
  my $self = shift;
  die(blessed($self) . " has not implemented the close() method!");
}

1;
