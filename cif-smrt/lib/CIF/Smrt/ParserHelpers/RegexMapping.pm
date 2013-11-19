package CIF::Smrt::ParserHelpers::RegexMapping;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;


has 'name' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'regex' => (
  is => 'ro',
  isa => 'RegexpRef',
  required => 1
);

has 'event_fields' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  required => 1
);

sub parse {
  my $self = shift;
  my $data = shift;
  my $ret = {};
  return undef unless(defined($data));
  my @matches = ($data =~ $self->regex);
  return undef if ($#matches == -1);
  my $i = 0;
  foreach my $field_name (@{$self->event_fields}) {
    $ret->{$field_name} = $matches[$i];
    $i++;
  }

  return $ret;
}

__PACKAGE__->meta->make_immutable;

1;
