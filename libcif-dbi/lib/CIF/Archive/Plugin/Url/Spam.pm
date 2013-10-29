package CIF::Archive::Plugin::Url::Spam;
use base 'CIF::Archive::UrlPluginBase';

use strict;
use warnings;

__PACKAGE__->table('url_spam');

use constant EVENT_REGEX => qr/^spam$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
