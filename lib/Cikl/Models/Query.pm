package Cikl::Models::Query;
use strict;
use warnings;
use Mouse;
require Cikl::DataTypes;
require Cikl::Models::QueryAddress;
require Cikl::Models::QueryRange;
use namespace::autoclean;

use constant QUERY_DEFAULT_LIMIT => 50;

around BUILDARGS => sub {
  my ($orig, $class, @params) = @_;
  my $args;
  if ( @params == 1 ) {
    $args = $params[0];
  } else {
    $args = {@params};
  }

  foreach my $key (keys(%$args)) {
    delete($args->{$key}) if (!defined($args->{$key}));
  }

  return $class->$orig(%$args);
};

has 'apikey' => (
  is => 'rw',
  isa => 'Cikl::DataTypes::LowercaseUUID',
  required => 1
);

has 'group' => (
  is => 'rw',
  isa => 'Cikl::DataTypes::LowerCaseStr',
  required => 0
);

has 'address_criteria' => (
  is => 'ro',
  isa => 'ArrayRef[Cikl::Models::QueryAddress]',
  required => 1,
  default => sub {[]}
);

has 'assessment' => (
  is => 'rw',
  isa => 'Str',
  required => 0
);

has 'confidence' => (
  is => 'rw',
  isa => 'Cikl::Models::QueryRange',
  required => 0
);

has 'reporttime' => (
  is => 'rw',
  isa => 'Cikl::Models::QueryRange',
  required => 0
);

has 'detecttime' => (
  is => 'rw',
  isa => 'Cikl::Models::QueryRange',
  required => 0
);

has 'nolog' => (
  is => 'rw',
  isa => 'Bool',
  default => 0,
  required => 1
);

has 'limit' => (
  is => 'rw',
  isa => 'Int',
  default => QUERY_DEFAULT_LIMIT,
  required => 1
);

sub to_hash {
  my $self = shift;
  my $ret = { %$self };
  $ret->{address_criteria} = [ map { $_->to_hash } @{$ret->{address_criteria}} ];
  foreach my $field (qw(confidence reporttime detecttime)) {
    $ret->{$field} = $ret->{$field}->to_hash() if (defined($ret->{$field}));
  }
  return $ret;
}

sub from_hash {
  my $class = shift;
  my $args = shift;
  $args->{address_criteria} = [ map { 
    Cikl::Models::QueryAddress->from_hash(%$_); } @{$args->{address_criteria} || []} ];
  foreach my $field (qw(confidence reporttime detecttime)) {
    $args->{$field} = Cikl::Models::QueryRange->from_hash($args->{$field}) if (defined($args->{$field}));
  }
  return $class->new($args);
}

__PACKAGE__->meta->make_immutable();

1;


