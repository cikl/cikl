package CIF::Archive::Plugin::Email::Whitelist;
use base 'CIF::Archive::EmailPluginBase';

use strict;
use warnings;

__PACKAGE__->table('email_whitelist');

use constant EVENT_REGEX => qr/whitelist/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
