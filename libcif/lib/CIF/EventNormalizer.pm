package CIF::EventNormalizer;

use strict;
use warnings;
use CIF qw/normalize_timestamp debug/;
use Module::Pluggable search_path => "CIF::EventNormalizers", 
      require => 1, sub_name => '_preprocessors';

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

  $self->{preprocessors} = $self->_init_preprocessors();

  return $self;
}

sub _init_preprocessors {
  my $self = shift;
  my @ret = ();
  foreach my $preprocessor (__PACKAGE__->_preprocessors()) {
    push(@ret, $preprocessor);
  }
  return \@ret;
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

  $r->{'detecttime'}        = $dt->epoch();
  $r->{'reporttime'}        = $rt->epoch();

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

  foreach my $p (@{$self->{preprocessors}}){
    $r = $p->process($r);
  }

  # TODO -- work-around, make this more configurable
  unless($r->{'severity'}){
    $r->{'severity'} = (defined($self->{severity_map}->{$r->{'assessment'}})) ? $self->{severity_map}->{$r->{'assessment'}} : 'medium';
  }
  return $r;
}

1;
