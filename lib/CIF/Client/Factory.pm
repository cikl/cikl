package CIF::Client::Factory;
use strict;
use warnings;
use CIF::Client;
use Data::Dumper;

sub instantiate {
  my $class = shift;
  my $args = shift;
  my $driver_class = $args->{driver} or 
    die("No driver provided for client args!");

  eval("require $driver_class;");
  if ($@) {
    die("Failed to load '$driver_class': $@");
  }

  my $transport = $driver_class->new($args);

  return CIF::Client->new(
    transport => $transport,
    apikey => $args->{apikey}
  );
}

1;


