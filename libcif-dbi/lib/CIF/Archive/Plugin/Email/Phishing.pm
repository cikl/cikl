package CIF::Archive::Plugin::Email::Phishing;
use base 'CIF::Archive::EmailPluginBase';

use strict;
use warnings;

__PACKAGE__->table('email_phishing');

use constant EVENT_REGEX => qr/phish/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
