package CIF::Archive::Plugin::Domain::Spam;
use base 'CIF::Archive::DomainPluginBase';

use strict;
use warnings;

__PACKAGE__->table('domain_spam');

use constant EVENT_REGEX => qr/^spam$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
