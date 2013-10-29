package CIF::Archive::Plugin::Infrastructure::Fastflux;
use base 'CIF::Archive::InfrastructurePluginBase';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_fastflux');

use constant EVENT_REGEX => qr/fastflux/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
