package Cikl::Report::ReportInterface;

use strict;
use warnings;
use Scalar::Util qw(blessed);

sub new {
  my $class = shift;

  my $self = {};
  bless $self, $class;
  return $self;
}

# Returns an arrayref, with the names of the fields that the body iterator will
# be yielding.
sub body_header {
  my $self = shift;
  die(blessed($self) . " has not implemented the body_header() method!");
}
sub body_iterator {
  my $self = shift;
  return sub {
    return undef;
  };
}

1;
