package CIF::Models::Submission;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use Data::Dumper;

sub new {
  my $class = shift;
  my $self = {};
  $self->{apikey} = shift;
  $self->{guid} = shift;
  $self->{event} = shift;
  bless $self, $class;
  return $self;
}

sub apikey { $_[0]->{apikey} };
sub guid { $_[0]->{guid} };
sub event { $_[0]->{event} };

sub encode {
  my $self = shift;
  my $encoder = shift;

  return $encoder->encode_submission($self->{apikey}, $self->{guid}, $self->{event});
}

sub decode {
  my $class = shift;
  my $encoder = shift;
  my $data = shift;
}

1;

