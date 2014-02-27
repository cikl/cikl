package Cikl::Router::Transport;

use strict;
use warnings;
use Mouse::Role;
use namespace::autoclean;

requires 'start';
requires 'stop';
requires 'shutdown';
requires 'register_service';

1;


