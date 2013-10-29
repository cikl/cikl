package CIF::Archive::Plugin::Infrastructure::Suspicious;
use base 'CIF::Archive::InfrastructurePluginBase';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_suspicious');

use constant EVENT_REGEX => qr/^suspicious$/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
