package CIF::Archive::Plugin::Url::Spamvertising;
use base 'CIF::Archive::UrlPluginBase';

use strict;
use warnings;

__PACKAGE__->table('url_spamvertising');

use constant EVENT_REGEX => qr/^spamvertising$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
