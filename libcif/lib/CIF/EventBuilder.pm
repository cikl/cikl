package CIF::EventBuilder;
use strict;
use warnings;
use CIF::Models::Event;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use CIF qw/normalize_timestamp debug/;
use Module::Pluggable search_path => "CIF::EventNormalizers", 
      require => 1, sub_name => '__preprocessors';

has 'default_event_data' => (
  is => 'bare',
  required => 1,
  reader => '_default_event_data'
);

has 'refresh' => (
  is => 'bare',
  reader => '_refresh',
  default => 0,
  required => 1
);

has 'goback' => (
  is => 'bare', 
  isa => 'Int',
  reader => '_goback',
  required => 1
);

has '_now' => (
  is => 'ro', 
  default => sub { DateTime->from_epoch(epoch => time()) },
  init_arg => undef
);

has '_preprocessors' => (
  traits => ['Array'],
  is => 'ro', 
  isa => 'ArrayRef[Str]',
  default => sub { [__preprocessors()]; },
  init_arg => undef
);

sub normalize {
  my $self = shift;
  my $r = shift;

  my $now  = $self->_now;
  my $dt = $r->{'detecttime'} || $now;
  my $rt = $r->{'reporttime'} || $now;

  $dt = normalize_timestamp($dt,$now);
  my $timestamp_epoch;

  if($self->_refresh){
    $rt = $now;
    $timestamp_epoch = $now->epoch();
  } else {
    $rt = normalize_timestamp($rt,$now);
    $timestamp_epoch = $dt->epoch();
  }

  $r->{'detecttime'}        = $dt->epoch();
  $r->{'reporttime'}        = $rt->epoch();

  if($timestamp_epoch < $self->_goback) { 
    return(undef);
  }

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
  foreach my $p (@{$self->_preprocessors}){
    $r = $p->process($r);
  }

  return $r;
}

sub build_event {
  my $self = shift;
  my $hashref = shift;
  if (!defined($hashref)) {
    die("build_event requires a hashref of arguments!");
  }
  my $merged_hash = {%{$self->_default_event_data}, %$hashref};
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

