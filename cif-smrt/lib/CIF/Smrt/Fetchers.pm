package CIF::Smrt::Fetchers;

use strict;
use warnings;

use Module::Pluggable search_path => "CIF::Smrt::Fetchers", 
      require => 1, sub_name => '_fetchers';

sub new {
  my $class = shift;

  my $self = {};

  bless $self, $class;

  $self->{fetchers} = $self->_init_fetchers();

  return $self;
}

sub _init_fetchers {
  my $self = shift;
  my @ret = ();
  foreach my $fetcher (__PACKAGE__->_fetchers()) {
    push(@ret, $fetcher);
  }
  return \@ret;
}

sub fetchers {
  my $self = shift;
  return @{$self->{fetchers}};
}

sub lookup {
  my $self = shift;
}

1;
