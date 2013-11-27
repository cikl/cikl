package CIF::MooseTypes::LowerCaseStr;
use strict;
use warnings;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

subtype "CIF::MooseTypes::LowerCaseStr", 
  as 'Str',
  where { !/\p{Upper}/ms },
  message { "Must be lowercase." };

coerce 'CIF::MooseTypes::LowerCaseStr',
  from 'Str',
  via { lc };

1;

