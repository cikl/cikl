package CIF::DataTypes::LowerCaseStr;
use strict;
use warnings;
use namespace::autoclean;
use Mouse::Util::TypeConstraints;

subtype "CIF::DataTypes::LowerCaseStr", 
  as 'Str',
  where { !/\p{Upper}/ms },
  message { "Must be lowercase." };

coerce 'CIF::DataTypes::LowerCaseStr',
  from 'Str',
  via { lc };

1;


