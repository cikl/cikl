package Cikl::Codecs::JSON;

use strict;
use warnings;
use Cikl::Models::Event;
require JSON::XS;
use Mouse;
use Cikl::Codecs::CodecRole;
use namespace::autoclean;

our $JSON = JSON::XS->new()->utf8(1);

with 'Cikl::Codecs::CodecRole';

sub content_type {
  return "application/json";
}

sub encode_event {
  my $self = shift;
  my $event = shift;
  return $JSON->encode($event->to_hash());
}

__PACKAGE__->meta->make_immutable;

1;
