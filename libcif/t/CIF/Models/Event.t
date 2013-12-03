package TestsFor::CIF::Models::Event;
use base qw(Test::Class);
use strict;
use warnings;
use Test::More;
use Test::Exception;
use CIF qw/generate_uuid_random/;

use CIF::Models::Event;

sub testing_class { 'CIF::Models::Event'; }

sub build {
  my %args = @_;
  return CIF::Models::Event->new(%args);
}

sub test_required_args : Test(4) {
  my $self = shift;

  my %working_args = (
    guid => generate_uuid_random(),
    assessment => "malware",
  );

  lives_and { isa_ok(CIF::Models::Event->new(%working_args), "CIF::Models::Event") };
  dies_ok { CIF::Models::Event->new() }  "die with no arguments";

  my %badargs = %working_args;
  delete($badargs{guid});
  dies_ok { CIF::Models::Event->new(%badargs) }  "requires guid";

  %badargs = %working_args;
  delete($badargs{assessment});
  dies_ok { CIF::Models::Event->new(%badargs) }  "requires assessment";
}

Test::Class->runtests;
