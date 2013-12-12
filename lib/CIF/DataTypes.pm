package CIF::DataTypes;
use strict;
use warnings;
use namespace::autoclean;
use Carp;
use Module::Pluggable search_path => "CIF::DataTypes", 
      require => 1, sub_name => 'load_cif_datatypes', 
      on_require_error => \&croak;

# Load all the plugins.
load_cif_datatypes();
1;
