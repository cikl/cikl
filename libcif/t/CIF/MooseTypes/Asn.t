package TestsFor::CIF::MooseTypes::Asn;
use base qw(Test::Class);
use strict;
use warnings;
use Test::More;
use Moose::Util::TypeConstraints;

use CIF::MooseTypes::Asn;

sub get_type : Test(setup) {
  my $self = shift;
  $self->{type} = find_type_constraint('CIF::MooseTypes::Asn');
}

sub test_constraint_obj : Test(2) {
  my $self = shift;
  isa_ok($self->{type}, 'Moose::Meta::TypeConstraint');
  is($self->{type}->name, 'CIF::MooseTypes::Asn', 'The typeconstraint should be named CIF::MooseTypes::Asn');
}

sub test_validation : Test(7) {
  my $self = shift;
  my $type = $self->{type};
  use Data::Dumper;
  ok(! $type->check(-1), "-1 is not a valid ASN");
  ok($type->check(0), "0 is a valid ASN");
  ok($type->check(1), "1 is a valid ASN");
  ok($type->check(65535), "65535 is a valid ASN");
  ok($type->check((2**32) - 1), "2^32 - 1 is a valid ASN");
  ok(! $type->check(2**32), "2^32 is not a valid ASN");
}


Test::Class->runtests;
