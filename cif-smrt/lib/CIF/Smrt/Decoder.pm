package CIF::Smrt::Decoder;

use strict;
use warnings;
use Moose;

has 'feedurl' => (
  is => 'ro',
  # isa => 'URL',
  required => 1
);

# This should return an array of supported mime types. These should match up
# with stuff that File::Type spits out.
#
sub mime_types { 
  my $class = shift;
  die("$class has not implemented the mime_types() method!");
}

sub decode {
  my $class = shift;
  my $dataref = shift;
  my $args = shift;
  die("$class has not implemented the decode() method!");
}

1;


