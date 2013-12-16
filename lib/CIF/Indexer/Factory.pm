package CIF::Indexer::Factory;
use strict;
use warnings;

sub instantiate {
  my $class = shift;
  my $indexer_config = shift;
  my $driver_class = $indexer_config->{driver} or 
    die("No driver provided for datastore config!");

  eval("use $driver_class;");
  if ($@) {
    die("Failed to load $driver_class: $@");
  }

  return $driver_class->new($indexer_config);
}

1;

