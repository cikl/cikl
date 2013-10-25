package CIF::Archive::Plugin::Url::Whitelist;
use base 'CIF::Archive::Plugin::Url';

use strict;
use warnings;

__PACKAGE__->table('url_whitelist');

use constant EVENT_REGEX => qr/whitelist/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
