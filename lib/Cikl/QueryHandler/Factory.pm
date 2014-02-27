package Cikl::QueryHandler::Factory;
use strict;
use warnings;

sub instantiate {
  my $class = shift;
  my $config = shift;
  my $driver_class = $config->{driver} or 
    die("No driver provided for query handler config!");

  eval("require $driver_class;");
  if ($@) {
    die("Failed to load '$driver_class': $@");
  }

  return $driver_class->new($config);
}

1;


