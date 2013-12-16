package CIF::Util::Flushable;

use strict;
use warnings;
use Mouse::Role;
use namespace::autoclean;

requires 'flush';

has 'commit_interval' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);

has 'commit_size' => (
  is => 'ro',
  isa => 'Num',
  required => 1
);


1;

