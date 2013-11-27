package CIF::MooseTypes::Ipv4;
use strict;
use warnings;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use Regexp::Common qw/net/;

use constant RE_IPV4 => qr/^$RE{'net'}{'IPv4'}$/;

subtype 'CIF::MooseTypes::Ipv4',
  as 'Str',
  where { $_ =~ RE_IPV4 },
  message { "Invalid Ipv4 address '$_'"} ;

1;
