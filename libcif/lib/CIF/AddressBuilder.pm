package CIF::AddressBuilder;
use strict;
use warnings;
use Carp qw/croak/;
use Module::Pluggable search_path => "CIF::Models::Address", require => 1,
  sub_name => "_plugins", on_require_error => sub { 
    my $plugin = shift;
    my $err = shift;
    warn "Failed to require $plugin\n";
    croak($err);
  }; 

use namespace::autoclean;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/create_address create_addresses/;

my $type_map = _build_type_map();

sub _build_type_map {
  my $ret = {};
  foreach my $module (_plugins()) {
    unless ($module->does("CIF::Models::AddressRole")) {
      die("$module must implement CIF::Models::AddressRole");
    }
    my $type = $module->type();
    if (my $existing = $ret->{$type}) {
      die("Cannot associate '$module' with the type '$type'. Already registered with $existing.");
    }
    $ret->{$type} = $module;
  }
  return $ret;
}

sub create_address {
  my $type = shift;
  my $value = shift;
  my $type_class = $type_map->{$type};
  unless($type_class) {
    die("Unknown type: $type");
  }
  return $type_class->new(value => $value);
}

sub create_addresses {
  my $protoevent = shift; # hashref
  my @ret;
  foreach my $type (keys(%{$type_map})) {
    if (my $value = delete($protoevent->{$type})) {
      push(@ret, create_address($type, $value));
    }
  }
  return \@ret;
}

1;

