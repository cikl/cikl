package TestsFor::CIF::Models::Address::asn;
use lib 'testlib';
use base qw(CIF::Models::Address::TestClass);
use strict;
use warnings;
use Test::More;

use CIF::Models::Address::asn;

sub testing_class { 'CIF::Models::Address::asn'; }

sub test_known_good_asns : Test(4) { 
  my $self = shift;

  ok($self->generate(0),  'accept 0');
  ok($self->generate(1234),  'accept 1234');
  ok($self->generate(65535),  'accept 65535');
  ok($self->generate((2**32) - 1),  'accept 2^32 - 1');
}

sub test_known_invalid_asns : Test(5) { 
  my $self = shift;

  ok(! $self->safe_generate(-1),  'reject -1');
  ok(! $self->safe_generate(2**32),  'reject 2^32');
  ok(! $self->safe_generate("asdf"),  'reject asdf');
  ok(! $self->safe_generate("   1234"),  'reject leading whitespace');
  ok(! $self->safe_generate("1234   "),  'reject trailing whitespace');
}

sub test_new_normalized : Test(2) {
  my $self = shift;

  is($self->generate_normalized('   1234')->value(), 
      1234, 'remove leading spaces');

  is($self->generate_normalized('1234   ')->value(), 
      1234, 'remove trailing spaces');

}

Test::Class->runtests;



