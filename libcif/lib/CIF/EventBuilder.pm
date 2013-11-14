package CIF::EventBuilder;
use strict;
use warnings;
use CIF::Models::Event;
use Moose;
use namespace::autoclean;

has 'normalizer' => (
  is => 'bare',
  required => 1,
  reader => '_normalizer'
);

has 'default_event_data' => (
  is => 'bare',
  required => 1,
  reader => '_default_event_data'
);

sub build_event {
  my $self = shift;
  my $hashref = shift;
  if (!defined($hashref)) {
    die("build_event requires a hashref of arguments!");
  }
  my $merged_hash = {%{$self->_default_event_data}, %$hashref};
  my $normalized = $self->_normalizer->normalize($merged_hash);
  if (!defined($normalized)) {
    return undef;
  }

  my $ret = CIF::Models::Event->new($normalized);
  return $ret;
}

__PACKAGE__->meta->make_immutable;

1;

