package CIF::DataTypes::Fqdn;
use strict;
use warnings;
use namespace::autoclean;
use CIF::DataTypes::LowerCaseStr;
use Mouse::Util::TypeConstraints;
use Regexp::Common qw/net/;

use constant FQDN_RE => qr/^$RE{net}{domain}{-rfc1101}{-nospace}$/ ;

subtype 'CIF::DataTypes::Fqdn',
  as 'CIF::DataTypes::LowerCaseStr',
  where { 
    $_ !~ /\s/  # No whitespace
    && $_ =~ FQDN_RE # proper fqdn
  },
  message { "Invalid fqdn '$_'"} ;

1;

