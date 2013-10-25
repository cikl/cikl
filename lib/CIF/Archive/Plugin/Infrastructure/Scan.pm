package CIF::Archive::Plugin::Infrastructure::Scan;
use base 'CIF::Archive::Plugin::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_scan');

use constant EVENT_REGEX => qr/^scan(?:(ning|ner))/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
