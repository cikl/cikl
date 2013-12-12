package CIF::Smrt::Parsers::ParseCsv;

use strict;
use warnings;

use Mouse;
use CIF::Smrt::Parsers::ParseDelim;
extends 'CIF::Smrt::Parsers::ParseDelim';
use namespace::autoclean;

use constant NAME => 'csv';
sub name { return NAME; }

has '+delimiter' => (
  default => ','
);

__PACKAGE__->meta->make_immutable;

1;
