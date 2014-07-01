package Cikl::ObservableBuilder;
use strict;
use warnings;
use Carp;
use Module::Pluggable search_path => "Cikl::Models::Observables", require => 1,
  sub_name => "_plugins", on_require_error => \&croak;

use namespace::autoclean;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/observable_from_protoevent create_observable create_observables/;

my $type_map = _build_type_map();

sub _build_type_map {
  my $ret = {};
  foreach my $module (_plugins()) {
    unless ($module->does("Cikl::Models::Observable")) {
      die("$module must implement Cikl::Models::Observable");
    }
    my $type = $module->type();
    if (my $existing = $ret->{$type}) {
      die("Cannot associate '$module' with the type '$type'. Already registered with $existing.");
    }
    $ret->{$type} = $module;
  }
  return $ret;
}

sub create_observable {
  my $type = shift;
  my $value = shift;
  my $type_class = $type_map->{$type};
  unless($type_class) {
    die("Unknown type: $type");
  }
  return $type_class->new_normalized(value => $value);
}

sub create_observables {
  my $protoevent = shift; # hashref
  my @ret;
  foreach my $type (keys(%{$type_map})) {
    if (my $value = delete($protoevent->{$type})) {
      push(@ret, create_observable($type, $value));
    }
  }
  return \@ret;
}

sub observable_from_protoevent {
  my $protoevent = shift; # hashref
  my $observable;
  foreach my $type (keys(%{$type_map})) {
    if (my $value = delete($protoevent->{$type})) {
      if (defined($observable)) {
        die("An event can only have one observable! Has: " . $observable->type() . " and $type");
      }
      $observable = create_observable($type, $value);
    }
  }
  return $observable;
}

1;

