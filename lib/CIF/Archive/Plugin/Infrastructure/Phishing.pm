package CIF::Archive::Plugin::Infrastructure::Phishing;
use base 'CIF::Archive::InfrastructurePluginBase';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_phishing');

use constant EVENT_REGEX => qr/phish/;

sub assessment_regex {
  return EVENT_REGEX;;
}

1;
