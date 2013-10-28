package CIF::Archive::Plugin::Domain::Suspicious;
use base 'CIF::Archive::DomainPluginBase';

use strict;
use warnings;

__PACKAGE__->table('domain_suspicious');

use constant EVENT_REGEX => qr/^suspicious$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
