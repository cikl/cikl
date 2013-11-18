package CIF::Smrt::Fetcher;

use strict;
use warnings;

sub new {
  my $class = shift;
  my $feedurl = shift;
  my $args = shift;

  my $self = {
    feedurl => $feedurl
  };
  bless $self, $class;
  return $self;
}

sub schemes { 
  my $class = shift;
  die("$class has not implemented the schemes() method!");
}

sub feedurl {
  my $self = shift;
  return $self->{feedurl};
}

sub fetch {
  my $class = shift;
  my $feedparser_config = shift;
  die("$class has not implemented the schemes() method!");
}

1;



