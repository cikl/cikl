package CIF::Archive::Plugin::Domain::Botnet;
use base 'CIF::Archive::DomainPluginBase';

use strict;
use warnings;

__PACKAGE__->table('domain_botnet');

use constant EVENT_REGEX => qr/^botnet$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
