package CIF::Archive::Plugin::Infrastructure::Spam;
use base 'CIF::Archive::Plugin::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_spam');

use constant EVENT_REGEX => qr/^spam$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
