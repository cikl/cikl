package Cikl::Models::Event;
use strict;
use warnings;
use Mouse;
use Mouse::Util::TypeConstraints;
use Cikl::DataTypes::LowerCaseStr;
use Cikl::DataTypes::Integer;
use Cikl::DataTypes::PortList;
use Cikl::Models::Observable;
use Cikl::Models::Observables;
use Cikl::ObservableBuilder qw/create_observable/;
use POSIX qw(strftime);
use namespace::autoclean;

has 'assessment' => (
  is => 'rw',
  isa => 'Cikl::DataTypes::LowerCaseStr',
  required => 1,
  coerce => 1
);

has 'source' => (
  is => 'rw',
  required => 1
);

has 'feed_provider' => (
  is => 'rw',
  required => 1
);

has 'feed_name' => (
  is => 'rw',
  required => 1
);

has 'observables' => (
  is => 'ro',
  isa => 'Cikl::Models::Observables',
  default => sub { Cikl::Models::Observables->new() }
);

has 'detect_time' => (
  is => 'rw',
  isa => "Maybe[Cikl::DataTypes::Integer]",
  coerce => 1
);

has 'import_time' => (
  is => 'rw',
  isa => "Cikl::DataTypes::Integer",
  coerce => 1,
  # Default to right now.
  default => sub { time() } 
);

has 'alternativeid' => (is => 'rw');
has 'alternativeid_restriction' => (is => 'rw');

has 'md5' => (is => 'rw');
has 'sha1' => (is => 'rw');
has 'sha256' => (is => 'rw');
has 'sha512' => (is => 'rw');

has 'portlist' => (
  is => 'rw',
  isa => 'Cikl::DataTypes::PortList'
);

has 'protocol' => (is => 'rw');
has 'restriction' => (is => 'rw');

has 'cc' => (is => 'rw');
has 'rir' => (is => 'rw');

use constant ISO8601_FORMAT => "%Y-%m-%dT%H:%M:%S+00:00";
sub to_hash {
  my $self = shift;
  my $ret = { %{$self} };
  my $import_time = $self->import_time();
  my $detect_time = $self->detect_time();
  if (defined($import_time)) {
    $ret->{import_time} = strftime(ISO8601_FORMAT, gmtime($import_time));
  }
  if (defined($detect_time)) {
    $ret->{detect_time} = strftime(ISO8601_FORMAT, gmtime($detect_time));
  }
  $ret->{observables} = $ret->{observables}->to_hash();
  return $ret;
}

__PACKAGE__->meta->make_immutable;

1;
