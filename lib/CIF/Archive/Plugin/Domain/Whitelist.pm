package CIF::Archive::Plugin::Domain::Whitelist;
use base 'CIF::Archive::DomainPluginBase';

use strict;
use warnings;

__PACKAGE__->table('domain_whitelist');

use constant EVENT_REGEX => qr/whitelist/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
