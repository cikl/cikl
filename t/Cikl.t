package TestsFor::Cikl;
use base qw(Test::Class);
use strict;
use warnings;
use Test::More;
use Test::Deep;
use Cikl;

sub test_is_uuid : Test(3) {
  my $self = shift;

  is(Cikl::is_uuid('asdf'), undef, "returns undef when it is not a uuid");
  is(Cikl::is_uuid('91570cce-cd0f-41b4-8bd5-540fdac50b0a'), 1, "returns 1 when it is a uuid");
  is(Cikl::is_uuid('91570CCE-CD0F-41B4-8BD5-540FDAC50B0A'), undef, "returns undef if the UUID contains any upper-case characters");
}

Test::Class->runtests;

