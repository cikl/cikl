package TestsFor::Cikl::EventBuilder;
use base qw(Test::Class);
use strict;
use warnings;
use Test::More;
use Test::Deep;

sub startup : Test(startup => 1) {
  use_ok( 'Cikl::EventBuilder' );
}

sub setup : Test(setup) {
  my $self = shift;
  my $builder = Cikl::EventBuilder->new();
  $self->{builder} = $builder;
}

sub test_normalize_empty_hash : Test(4) {
  my $self = shift;
  my $builder = $self->{builder};

  my $r = $builder->normalize({});
  my $count = keys %$r;
  is($count, 1, "it has three keys");
  ok(!exists($r->{import_time}), "it has no 'import_time'");
  ok(!exists($r->{detect_time}), "it has no 'detect_time'");
  cmp_deeply($r->{observables}, [], "it has an empty 'observables' array");
}

sub test_build_basic : Test(6) {
  my $self = shift;
  my $builder = $self->{builder};

  my $data = {
    assessment => 'whitelist'
  };
  my $before = time();
  my $e = $builder->build_event($data);
  my $after = time();
  isa_ok($e, "Cikl::Models::Event", "it's an Event");
  cmp_ok($e->import_time(), '>=', $before, "it's import_time is correct");
  cmp_ok($e->import_time(), '<=', $after, "it's import_time is correct");
  is($e->detect_time(), undef, "it an undefined 'detect_time'");
  is($e->assessment(), "whitelist", "it has the provided assessment");
  ok($e->observables()->is_empty(), "it has no observables");
}

sub test_build_basic_ipv4 : Test(8) {
  my $self = shift;
  my $builder = $self->{builder};

  my $data = {
    assessment => 'whitelist',
    ipv4 => '1.2.3.4'
  };

  my $before = time();
  my $e = $builder->build_event($data);
  my $after = time();
  isa_ok($e, "Cikl::Models::Event", "it's an Event");
  cmp_ok($e->import_time(), '>=', $before, "it's import_time is correct");
  cmp_ok($e->import_time(), '<=', $after, "it's import_time is correct");
  is($e->detect_time(), undef, "it has a default 'detect_time'");
  is($e->assessment(), "whitelist", "it has the provided assessment");
  is($e->observables()->count(), 1, "it has one observable");

  isa_ok($e->observables()->ipv4()->[0], 'Cikl::Models::Observables::ipv4', "the address is an ipv4");
  is($e->observables()->ipv4()->[0]->value(), '1.2.3.4', "the address 1.2.3.4");
}
TestsFor::Cikl::EventBuilder->runtests;

