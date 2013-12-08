package CIF::DataTypes::Asn;
use strict;
use warnings;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

use constant MAX_ASN => 2**32 - 1;

subtype 'CIF::DataTypes::Asn',
  as 'Int',
  where { $_ >= 0 && $_ <= MAX_ASN },
  message { "Invalid ASN: $_"} ;
1;


