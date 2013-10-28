package CIF::Archive::Plugin::Url::Botnet;
use base 'CIF::Archive::UrlPluginBase';

use strict;
use warnings;

__PACKAGE__->table('url_botnet');

use constant EVENT_REGEX => qr/^botnet$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
