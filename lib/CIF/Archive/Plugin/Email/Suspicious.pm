package CIF::Archive::Plugin::Email::Suspicious;
use base 'CIF::Archive::EmailPluginBase';

use strict;
use warnings;

__PACKAGE__->table('email_suspicious');

use constant EVENT_REGEX => qr/suspicious/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
