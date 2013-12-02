package TestsFor::CIF::Models::Address::fqdn;
use lib 'testlib';
use base qw(CIF::Models::Address::TestClass);
use strict;
use warnings;
use Test::More;

use CIF::Models::Address::fqdn;

sub testing_class { "CIF::Models::Address::fqdn"; }

sub test_known_good_fqdns : Test(2) { 
  my $self = shift;

  ok($self->generate("foo.com"),  "accept foo.com");
  ok($self->generate("www.foo.com"),  "accept www.foo.com");
}

sub test_known_invalid_fqdns : Test(3) { 
  my $self = shift;
  ok(! $self->safe_generate("asdf/qwer"), "reject / char");
  ok(! $self->safe_generate(""), "reject empty string");
  ok(! $self->safe_generate("not an fqdn"), "reject string with whitespace");
}

sub test_new_normalized : Test(3) {
  my $self = shift;
  is($self->generate_normalized("FOO.COM")->value(), 
      'foo.com', "downcase fqdn");

  is($self->generate_normalized("   bar.com")->value(), 
      'bar.com', "remove leading spaces");

  is($self->generate_normalized("bar.com   ")->value(), 
      'bar.com', "remove trailing spaces");

}

Test::Class->runtests;

