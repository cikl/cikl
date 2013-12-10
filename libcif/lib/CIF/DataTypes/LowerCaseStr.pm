package CIF::DataTypes::LowerCaseStr;
use strict;
use warnings;
use namespace::autoclean;
use Mouse::Util::TypeConstraints;
use constant RE_UPPER => qr/\p{Upper}/;
subtype "CIF::DataTypes::LowerCaseStr", 
  as 'Str',
  where { ! RE_UPPER },
  message { "Must be lowercase." };

coerce 'CIF::DataTypes::LowerCaseStr',
  from 'Str',
  via { lc };

1;

