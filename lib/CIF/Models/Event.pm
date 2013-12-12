package CIF::Models::Event;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF qw(generate_uuid_random);
require JSON;
use Mouse;
use Mouse::Util::TypeConstraints;
use CIF::DataTypes;
use CIF::Models::AddressRole;
use CIF::AddressBuilder qw/create_address/;
use namespace::autoclean;

has 'group' => (
  is => 'rw',
  isa => 'CIF::DataTypes::LowerCaseStr',
  required => 1,
);

has 'assessment' => (
  is => 'rw',
  isa => 'CIF::DataTypes::LowerCaseStr',
  required => 1,
  coerce => 1
);

has 'description' => (
  is => 'rw',
  isa => 'CIF::DataTypes::LowerCaseStr',
  default => sub { 'unknown' },
  coerce => 1
);

has 'addresses' => (
  is => 'rw',
  isa => 'ArrayRef[CIF::Models::AddressRole]',
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
  isa => 'CIF::DataTypes::PortList'
);

has 'protocol' => (is => 'rw');
has 'purpose' => (is => 'rw');
has 'relatedid' => (is => 'rw');
has 'restriction' => (is => 'rw');
has 'severity' => (is => 'rw');
has 'source' => (is => 'rw');
has 'timestamp' => (is => 'rw');

has 'cc' => (is => 'rw');
has 'rir' => (is => 'rw');

sub address {
  my $self = shift;
  if (my $address = $self->addresses->[0]) {
    return $address->as_string();
  }
  return undef;
}

sub to_hash {
  my $ret = { %{$_[0]} };
  $ret->{addresses}  = [ map {
        {type => $_->type, value => $_->value()}
      } @{$ret->{addresses}} ];

  return $ret;
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  my @addresses = map {create_address($_->{type}, $_->{value});} @{$data->{addresses} || []};
  $data->{addresses} = \@addresses;
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
