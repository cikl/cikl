package CIF::MooseTypes;
use strict;
use warnings;
use namespace::autoclean;
use Carp;
use Module::Pluggable search_path => "CIF::MooseTypes", 
      require => 1, sub_name => 'load_cif_moosetypes', 
      on_require_error => \&croak;

# Load all the plugins.
load_cif_moosetypes();
1;
