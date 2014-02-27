package Cikl::Report::Formatter;

use strict;
use warnings;
use Scalar::Util qw(blessed);

sub new {
  my $class = shift;

  my $self = {};
  bless $self, $class;
  return $self;
}

# This method accepts a context (report) and a filehandle. The generated 
# report will be output to the filehandle.
sub generate_report {
  my $self = shift;
  my $context = shift;
  my $fh = shift;
  die(blessed($self) . " has not implemented the generate_report() method!");
}

1;
