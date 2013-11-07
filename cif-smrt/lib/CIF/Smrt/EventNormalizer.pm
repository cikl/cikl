package CIF::Smrt::EventNormalizer;

use strict;
use warnings;
use CIF qw/normalize_timestamp debug/;
use Module::Pluggable search_path => ['CIF::Smrt::Plugin::Preprocessor'];

sub new {
  my $class = shift;
  my $args = shift;
  
  my $self = {
    refresh => $args->{refresh} || 0,
    severity_map => $args->{severity_map},
    goback => $args->{goback},
    now => DateTime->from_epoch(epoch => time())
  };
  bless $self, $class;

  return $self;
}

sub normalize {
  my $self = shift;
  my $r = shift;

  my $now  = $self->{now};
  my $dt = $r->{'detecttime'} || $now;
  my $rt = $r->{'reporttime'} || $now;

  $dt = normalize_timestamp($dt,$now);
  my $timestamp_epoch;

  if($self->{refresh}){
    $rt = $now;
    $timestamp_epoch = $now->epoch();
  } else {
    $rt = normalize_timestamp($rt,$now);
    $timestamp_epoch = $dt->epoch();
  }

  $r->{'detecttime'}        = $dt->ymd().'T'.$dt->hms().'Z';
  $r->{'reporttime'}        = $rt->ymd().'T'.$rt->hms().'Z';

  if($timestamp_epoch < $self->{goback}) { 
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

  foreach my $p (__PACKAGE__->plugins()){
    $r = $p->process($r);
  }

  # TODO -- work-around, make this more configurable
  unless($r->{'severity'}){
    $r->{'severity'} = (defined($self->{severity_map}->{$r->{'assessment'}})) ? $self->{severity_map}->{$r->{'assessment'}} : 'medium';
  }
  return $r;
}

1;
