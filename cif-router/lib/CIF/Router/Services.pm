package CIF::Router::Services;

use strict;
use warnings;

use Module::Pluggable search_path => "CIF::Router::Services",
      require => 1, sub_name => '_services';

sub new {
  my $class = shift;

  my $self = {};

  bless $self, $class;

  $self->{service_map} = $self->_init_services();

  return $self;
}

sub _init_services {
  my $self = shift;
  my $ret = {};
  foreach my $service (__PACKAGE__->_services()) {
    my $name = $service->name();
    if (!defined($name)) {
      die("Service type/name not defined for $service");
    }
    if (my $existing = $ret->{$name}) {
      die("Cannot associate $service with $name. Already registered with $existing.");
    }
    $ret->{$name} = $service;
  }
  return $ret;
}

sub lookup {
  my $self = shift;
  my $name= shift;
  return($self->{service_map}->{$name});
}

1;
