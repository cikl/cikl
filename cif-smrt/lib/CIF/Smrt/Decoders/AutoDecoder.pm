package CIF::Smrt::Decoders::AutoDecoder;

use strict;
use warnings;
use CIF::Smrt::DecoderRole;
use File::Type;
use Module::Pluggable search_path => "CIF::Smrt::Decoders", 
      require => 1, sub_name => '_decoders';

use namespace::autoclean;
use Moose;
with 'CIF::Smrt::DecoderRole';

has 'decoder_map' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  builder => "_init_decoders"
);

has 'decoder_args' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { return {} }
);

sub _init_decoders {
  my $self = shift;
  my $ret = {};
  foreach my $decoder (_decoders()) {
    next unless ($decoder->meta->does_role("CIF::Smrt::AutoDecodableRole"));

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

sub decode {
    my $self = shift;
    my $content_ref = shift;

    my $ft = File::Type->new();
    my $type = $ft->mime_type($$content_ref);
    my $decoder_class = $self->decoder_map->{$type};
    unless($decoder_class) {
      debug("Don't know how to decode $type");
      return $content_ref;
    }

    my $decoder = $decoder_class->new(%{$self->decoder_args});
    return $decoder->decode($content_ref);
}

__PACKAGE__->meta->make_immutable();

1;


