package CIF::Smrt::Fetcher;

use strict;
use warnings;

sub new {
  my $class = shift;
  my $args = shift;

  my $self = {};
  bless $self, $class;
  return $self;
}

sub schemes { 
  my $class = shift;
  die("$class has not implemented the schemes() method!");
}

sub fetch {
  my $class = shift;
  my $feedparser_config = shift;
  die("$class has not implemented the schemes() method!");
}

1;



