package CIF::Archive::Plugin::Domain::Spamvertising;
use base 'CIF::Archive::DomainPluginBase';

use strict;
use warnings;

__PACKAGE__->table('domain_spamvertising');

use constant EVENT_REGEX => qr/^spamvertising$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
