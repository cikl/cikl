package CIF::Smrt::Decoders;

use strict;
use warnings;
use File::Type;
use CIF qw/debug/;

use Module::Pluggable search_path => "CIF::Smrt::Decoders", 
      require => 1, sub_name => '_decoders';

sub new {
  my $class = shift;

  my $self = {};

  bless $self, $class;

  $self->{decoder_map} = $self->_init_decoders();

  return $self;
}

sub _init_decoders {
  my $self = shift;
  my $ret = {};
  foreach my $decoder (__PACKAGE__->_decoders()) {
    foreach my $mime_type ($decoder->mime_types()) {
      if (defined($ret->{$mime_type})) {
        my $existing = $ret->{$mime_type};
        die("Cannot associate $decoder with $mime_type. Already registered with $existing.");
      }
      $ret->{$mime_type} = $decoder;
    }
  }
  return $ret;
}

sub lookup {
  my $self = shift;
  my $mime_type = shift;
  return($self->{decoder_map}->{$mime_type});
}

sub autodecode {
  my $self = shift;
  my $content_ref = shift;
  my $feedparser_config = shift;
  my $ft = File::Type->new();
  my $type = $ft->mime_type($$content_ref);
  my $decoder = $self->lookup($type);
  unless($decoder) {
    debug("Don't know how to decode $type");
    return $content_ref;
  }
  return $decoder->decode($content_ref, $feedparser_config);
}

1;
