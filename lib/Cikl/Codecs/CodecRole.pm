package Cikl::Codecs::CodecRole;
use strict;
use warnings;

use Mouse::Role;
use namespace::autoclean;

requires 'content_type';

requires 'encode_hostinfo';
requires 'decode_hostinfo';
requires 'encode_query';
requires 'decode_query';
requires 'encode_query_results';
requires 'decode_query_results';
requires 'encode_event';
requires 'decode_event';
requires 'encode_submission';
requires 'decode_submission';

1;
