package CIF::Models::Event;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF qw(generate_uuid_random);
require JSON;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Aliases;
use MooseX::SlurpyConstructor;
use CIF::MooseTypes;
use namespace::autoclean;

has 'guid' => (
  is => 'rw',
  isa => 'CIF::MooseTypes::LowercaseUUID',
  required => 1,
);

has 'id' => (
  is => 'rw',
  isa => 'CIF::MooseTypes::LowercaseUUID',
  default => sub { generate_uuid_random() },
  alias => 'uuid'
);

has 'assessment' => (
  is => 'rw',
  isa => 'CIF::MooseTypes::LowerCaseStr',
  required => 1,
  coerce => 1
);

has 'description' => (
  is => 'rw',
  isa => 'CIF::MooseTypes::LowerCaseStr',
  default => sub { 'unknown' },
  coerce => 1
);

has 'address' => (
  is => 'rw',
  isa => 'CIF::MooseTypes::LowerCaseStr',
  coerce => 1
);

has 'detecttime' => (
  is => 'rw',
  isa => "Int"
);

has 'reporttime' => (
  is => 'rw',
  isa => "Int"
);

has 'address_mask' => (is => 'rw');
has 'alternativeid' => (is => 'rw');
has 'alternativeid_restriction' => (is => 'rw');
has 'carboncopy' => (is => 'rw');
has 'confidence' => (is => 'rw');
has 'contact' => (is => 'rw');
has 'contact_email' => (is => 'rw');
has 'hash' => (is => 'rw');
has 'lang' => (is => 'rw');

has 'malware_md5' => (is => 'rw');
has 'malware_sha1' => (is => 'rw');
has 'md5' => (is => 'rw');
has 'sha1' => (is => 'rw');

has 'method' => (is => 'rw');

has 'portlist' => (
  is => 'rw',
  isa => 'CIF::MooseTypes::PortList'
);

has 'protocol' => (is => 'rw');
has 'purpose' => (is => 'rw');
has 'relatedid' => (is => 'rw');
has 'restriction' => (is => 'rw');
has 'severity' => (is => 'rw');
has 'source' => (is => 'rw');
has 'timestamp' => (is => 'rw');

has 'asn' => (is => 'rw');
has 'cc' => (is => 'rw');
has 'rir' => (is => 'rw');

# This stores attributes that haven't been explicitly defined.
has 'other_attributes' => (
  is => 'rw',
  slurpy => 1
);

sub to_hash {
  my $self = shift;
  my $data = {};
  foreach my $key (keys %$self) {
    $data->{$key} = $self->{$key};
  }
  return $data;
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  return $class->new($data);
}

sub to_json {
  my $self = shift;
  return JSON::encode_json($self->to_hash());
}

sub from_json {
  my $class = shift;
  my $data = JSON::decode_json(shift);

  return($class->from_hash($data));
}

__PACKAGE__->meta->make_immutable;

1;
