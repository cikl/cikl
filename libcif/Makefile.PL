use strict;
use warnings;

use inc::Module::Install;
require ExtUtils::MakeMaker;

name 'libcif';
version '1.5';
license 'lgpl';

tests 't/*.t t/*/*.t';

WriteAll;
