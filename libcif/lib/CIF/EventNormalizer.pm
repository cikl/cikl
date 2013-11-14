package CIF::EventNormalizer;

use strict;
use warnings;
use CIF qw/normalize_timestamp debug/;
use Moose;
use namespace::autoclean;
use Module::Pluggable search_path => "CIF::EventNormalizers", 
      require => 1, sub_name => '__preprocessors';


has 'refresh' => (
  is => 'bare',
  reader => '_refresh',
  default => 0,
  required => 1
);

has 'severity_map' => (
  is => 'bare',
  reader => '_severity_map',
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

  unless($r->{'assessment'}){
    debug('WARNING: config missing an assessment') if($::debug);
    $r->{'assessment'} = 'unknown';
  }

  foreach my $p (@{$self->_preprocessors}){
    $r = $p->process($r);
  }

  # TODO -- work-around, make this more configurable
  unless($r->{'severity'}){
    my $sm = $self->_severity_map;
    if (my $severity = $self->_severity_map->{$r->{'assessment'}}) {
      $r->{'severity'} = $severity;
    } else {
      $r->{'severity'} = 'medium'; 
    }
  }
  return $r;
}

__PACKAGE__->meta->make_immutable;

1;
