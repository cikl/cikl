package CIF::MooseTypes::LowercaseUUID;
use strict;
use warnings;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use CIF::MooseTypes::LowerCaseStr;
use CIF qw(is_uuid);

subtype "CIF::MooseTypes::LowercaseUUID", 
  as 'Str',
  where { is_uuid($_) && ($_ !~ /[A-Z]/) },
  message { "Not a UUID with all lower-case characters: " . $_ };

1;

