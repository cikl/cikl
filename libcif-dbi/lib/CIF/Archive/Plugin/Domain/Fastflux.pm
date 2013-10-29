package CIF::Archive::Plugin::Domain::Fastflux;
use base 'CIF::Archive::DomainPluginBase';

use strict;
use warnings;

__PACKAGE__->table('domain_fastflux');

use constant EVENT_REGEX => qr/fastflux/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
