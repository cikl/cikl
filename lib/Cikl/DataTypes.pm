package Cikl::DataTypes;
use strict;
use warnings;
use namespace::autoclean;
use Carp;
use Module::Pluggable search_path => "Cikl::DataTypes", 
      require => 1, sub_name => 'load_cikl_datatypes', 
      on_require_error => \&croak;

# Load all the plugins.
load_cikl_datatypes();
1;
