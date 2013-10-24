package CIF::Archive::Plugin::Domain::Phishing;
use base 'CIF::Archive::Plugin::Domain';

use strict;
use warnings;

__PACKAGE__->table('domain_phishing');

use constant EVENT_REGEX => qr/phish/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
