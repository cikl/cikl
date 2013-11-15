package CIF::MooseTypes;
use strict;
use warnings;
use Moose::Util::TypeConstraints;
use CIF qw(generate_uuid_ns is_uuid);

subtype "CIF::MooseTypes::LowerCaseStr", 
  as 'Str',
  where { !/\p{Upper}/ms },
  message { "Must be lowercase." };

coerce 'CIF::MooseTypes::LowerCaseStr',
  from 'Str',
  via { lc };

subtype "CIF::MooseTypes::LowercaseUUID", 
  as 'Str',
  where { is_uuid($_) && ($_ !~ /[A-Z]/) },
  message { "Not a UUID with all lower-case characters: " . $_ };

1;
