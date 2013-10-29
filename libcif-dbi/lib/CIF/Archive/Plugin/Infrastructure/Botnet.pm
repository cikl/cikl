package CIF::Archive::Plugin::Infrastructure::Botnet;
use base 'CIF::Archive::InfrastructurePluginBase';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_botnet');

use constant EVENT_REGEX => qr/^botnet$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
