package CIF::Archive::Plugin::Infrastructure::Spamvertising;
use base 'CIF::Archive::InfrastructurePluginBase';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_spamvertising');

use constant EVENT_REGEX => qr/^spamvertising$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
