package TestsFor::CIF::Models::Address::ipv4;
use lib 'testlib';
use base qw(CIF::Models::Address::TestClass);
use strict;
use warnings;
use Test::More;

use CIF::Models::Address::ipv4;

sub testing_class { "CIF::Models::Address::ipv4"; }

sub test_known_valid_ipv4 : Test(2) { 
  my $self = shift;

  ok($self->generate("0.0.0.0"),  "accept 0.0.0.0");
  ok($self->generate("255.255.255.255"),  "accept 255.255.255.255");
}

sub test_known_invalid_ipv4 : Test(4) { 
  my $self = shift;
  ok(! $self->safe_generate("256.1.1.1"),  "reject 256.1.1.1");
  ok(! $self->safe_generate("1.256.1.1"),  "reject 1.256.1.1");
  ok(! $self->safe_generate("1.1.256.1"),  "reject 1.1.256.1");
  ok(! $self->safe_generate("1.1.1.256"),  "reject 1.1.1.256");
}

sub test_cidrs : Test(1) { 
  my $self = shift;
  ok(! $self->safe_generate("10.0.0.0/24"),  "reject cidr");
}

Test::Class->runtests;

