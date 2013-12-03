package TestsFor::CIF::Models::Address::email;
use lib 'testlib';
use base qw(CIF::Models::Address::TestClass);
use strict;
use warnings;
use Test::More;

use CIF::Models::Address::email;

sub testing_class { 'CIF::Models::Address::email'; }

sub test_known_good_emails : Test(2) { 
  my $self = shift;

  ok($self->generate('foo@bar.com'),  'accept foo@bar.com');
  ok($self->generate('foo.bar@bar.com'),  'accept foo.bar@bar.com');
}

sub test_invalid_characters : Test(12) { 
  my $self = shift;
  my @invalid_chars = (
    '(', ')', '<', '>', '@', 
    ',', ';', ':', '\\', '"', 
    '[', ']' );
  foreach my $char (@invalid_chars) {
    ok(! $self->safe_generate('asdf' . $char . 'qwer@bar.com'), 'reject ' . $char . ' char');
  }
}
sub test_whitespace : Test(4) { 
  my $self = shift;
  ok(! $self->safe_generate(''), 'reject empty string');
  ok(! $self->safe_generate('bad address@foo.com'), 'reject string with whitespace');
  ok(! $self->safe_generate('   address@foo.com'), 'reject leading whitespace');
  ok(! $self->safe_generate('address@foo.com   '), 'reject trailing whitespace');
}
#
sub test_new_normalized : Test(3) {
  my $self = shift;
  is($self->generate_normalized('ASDF@FOO.COM')->value(), 
      'asdf@foo.com', 'downcase fqdn');

  is($self->generate_normalized('   asdf@bar.com')->value(), 
      'asdf@bar.com', 'remove leading spaces');

  is($self->generate_normalized('asdf@bar.com   ')->value(), 
      'asdf@bar.com', 'remove trailing spaces');

}

Test::Class->runtests;


