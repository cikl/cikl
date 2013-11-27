package CIF::MooseTypes::Fqdn;
use strict;
use warnings;
use namespace::autoclean;
use CIF::MooseTypes::LowerCaseStr;
use Moose::Util::TypeConstraints;
use Regexp::Common qw/net/;

use constant FQDN_RE => qr/^$RE{net}{domain}{-rfc1101}{-nospace}$/ ;

subtype 'CIF::MooseTypes::Fqdn',
  as 'CIF::MooseTypes::LowerCaseStr',
  where { $_ =~ FQDN_RE },
  message { "Invalid fqdn '$_'"} ;

coerce 'CIF::MooseTypes::Fqdn',
  from 'Str',
  via { lc };

1;

