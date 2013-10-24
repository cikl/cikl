package CIF::Archive::Plugin::Email::Registrant;
use base 'CIF::Archive::Plugin::Email';

use strict;
use warnings;

__PACKAGE__->table('email_registrant');

use constant EVENT_REGEX => qr/registrant/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
