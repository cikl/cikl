package CIF::EventBuilder;
use strict;
use warnings;
use CIF::Models::Event;
use CIF::AddressBuilder qw/address_from_protoevent/;
use Mouse;
use namespace::autoclean;
use Try::Tiny;
use DateTime;
use CIF qw/debug/;
use CIF::Util::TimeHelpers qw/normalize_timestamp/;

has 'default_event_data' => (
  is => 'rw',
  isa => 'HashRef',
  required => 1,
  default => sub { return {}; }
);

has 'refresh' => (
  is => 'rw',
  isa => 'Bool',
  default => 0,
  required => 1
);

has 'not_before' => (
  is => 'rw', 
  isa => 'Int',
  required => 1,
  default => sub {
    return DateTime->now()->subtract(days => 3)->epoch();
  }
);

has '_now' => (
  is => 'ro', 
  default => sub { time() },
  init_arg => undef
);

sub merge_default_event_data {
  my $self = shift;
  my $data_to_merge = shift;
  my $merged_data = {%{$self->default_event_data}, %$data_to_merge};
  $self->default_event_data($merged_data);
}

sub normalize {
  my $self = shift;
  my $r = shift;

  my $now  = $self->_now;
  my $dt = normalize_timestamp($r->{detecttime}, $now);
  if($dt < $self->not_before) {
    return(undef);
  }
  $r->{detecttime} = $dt;

  $r->{reporttime} = $self->refresh ? $now : 
      normalize_timestamp($r->{reporttime}, $now);

  $r->{address} = address_from_protoevent($r);
  # MPR: Disabling value expansion, for now.
#  foreach my $key (keys %$r){
#    my $v = $r->{$key};
#    next unless($v);
#    if($v =~ /<(\S+)>/){
#      my $value_to_expand = $1;
#      my $x = $r->{$value_to_expand};
#      if($x){
#        $r->{$key} =~ s/<\S+>/$x/;
#      }
#    }
#  }
  return $r;
}

sub build_event {
  my $self = shift;
  my $hashref = shift;
  if (!defined($hashref)) {
    die("build_event requires a hashref of arguments!");
  }
  my $merged_hash = {%{$self->default_event_data}, %$hashref};
  my $normalized = $self->normalize($merged_hash);
  if (!defined($normalized)) {
    return undef;
  }

  my $event;
  my $err;
  try {
    $event = CIF::Models::Event->new($normalized);
  } catch {
    $err = shift;
  };
  if ($err) {
    die("Failed to build event. Likely missing a required field: $err");
  }
  return $event;
}

__PACKAGE__->meta->make_immutable;

1;

