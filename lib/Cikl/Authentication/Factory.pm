package Cikl::Authentication::Factory;
use strict;
use warnings;

sub instantiate {
  my $class = shift;
  my $auth_config = shift;
  my $driver_class = $auth_config->{driver} or 
    die("No driver provided for auth config!");

  eval("require $driver_class;");
  if ($@) {
    die("Failed to load '$driver_class': $@");
  }

  return $driver_class->new($auth_config);
}

1;

