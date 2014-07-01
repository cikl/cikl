package Cikl::Codecs::CodecRole;
use strict;
use warnings;

use Mouse::Role;
use namespace::autoclean;

requires 'content_type';

requires 'encode_event';

1;
