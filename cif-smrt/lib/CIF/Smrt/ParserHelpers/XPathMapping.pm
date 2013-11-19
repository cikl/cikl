package CIF::Smrt::ParserHelpers::XPathMapping;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;


has 'event_field' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'xpath' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

__PACKAGE__->meta->make_immutable;

1;

