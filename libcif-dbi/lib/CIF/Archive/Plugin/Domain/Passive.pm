package CIF::Archive::Plugin::Domain::Passive;
use base 'CIF::Archive::DomainPluginBase';

use strict;
use warnings;

__PACKAGE__->table('domain_passive');

use constant EVENT_REGEX => qr/^passive$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
