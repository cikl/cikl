package Cikl::DataTypes::LowercaseUUID;
use strict;
use warnings;
use namespace::autoclean;
use Mouse::Util::TypeConstraints;
use Cikl::DataTypes::LowerCaseStr;
use Cikl qw(is_uuid);

subtype "Cikl::DataTypes::LowercaseUUID", 
  as 'Str',
  where { is_uuid($_) },
  message { "Not a UUID with all lower-case characters: " . $_ };

1;

