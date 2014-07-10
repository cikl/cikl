package TestsFor::Cikl::Models::Event;
use base qw(Test::Class);
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;
use Cikl::Models::Event;
use Cikl::ObservableBuilder qw/create_observable/;

sub testing_class { 'Cikl::Models::Event'; }

sub build {
  my %args = @_;
  return Cikl::Models::Event->new(%args);
}

sub test_required_args : Test(3) {
  my $self = shift;

  my %working_args = (
    assessment => "malware",
    source     => 'cikl_smrt',
    feed_name  => 'test_feed',
    feed_provider => 'test_provider'
  );

  lives_and { isa_ok(Cikl::Models::Event->new(%working_args), "Cikl::Models::Event") };
  dies_ok { Cikl::Models::Event->new() }  "die with no arguments";

  my %badargs = %working_args;
  delete($badargs{assessment});
  dies_ok { Cikl::Models::Event->new(%badargs) }  "requires assessment";
}

sub test_no_observables : Test(2) {
  my $self = shift;

  my $assessment = "malware";
  my $now = time();
  my $event = Cikl::Models::Event->new({
      assessment => $assessment,
      import_time => 1405018319,
      detect_time => 1405018318,
      source     => 'cikl_smrt',
      feed_name  => 'test_feed',
      feed_provider => 'test_provider'
    });
  isa_ok($event, "Cikl::Models::Event", "it's an event");

  cmp_deeply($event->to_hash(), 
    {
      assessment => $assessment,
      import_time => '2014-07-10T18:51:59+00:00',
      detect_time => '2014-07-10T18:51:58+00:00',
      observables => {},
      source     => 'cikl_smrt',
      feed_name  => 'test_feed',
      feed_provider => 'test_provider'
    },
    "to_hash generates the right data");
}

sub test_with_observables : Test(2) {
  my $self = shift;

  my $assessment = "malware";
  my $now = time();
  my $event = Cikl::Models::Event->new({
      assessment => $assessment,
      import_time => 1405018319,
      source     => 'cikl_smrt',
      feed_name  => 'test_feed',
      feed_provider => 'test_provider'
    });
  isa_ok($event, "Cikl::Models::Event", "it's an event");

  my $ipv4 = create_observable('ipv4', '1.2.3.4');
  my $fqdn1 = create_observable('fqdn', 'google.com');
  my $fqdn2 = create_observable('fqdn', 'yahoo.com');
  $event->observables->add($ipv4);
  $event->observables->add($fqdn1);
  $event->observables->add($fqdn2);

  cmp_deeply($event->to_hash(), 
    {
      assessment => $assessment,
      import_time => '2014-07-10T18:51:59+00:00',
      source     => 'cikl_smrt',
      feed_name  => 'test_feed',
      feed_provider => 'test_provider',
      observables => {
        ipv4 => [
          {
            ipv4 => '1.2.3.4'
          }
        ],
        fqdn => [
          {
            fqdn => 'google.com'
          },
          {
            fqdn => 'yahoo.com'
          }
        ]
      }
    },
    "to_hash generates the right data");
}

Test::Class->runtests;
