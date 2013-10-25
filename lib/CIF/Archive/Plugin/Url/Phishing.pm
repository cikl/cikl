package CIF::Archive::Plugin::Url::Phishing;
use base 'CIF::Archive::Plugin::Url';

use strict;
use warnings;

__PACKAGE__->table('url_phishing');

use constant EVENT_REGEX => qr/phish/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
