package CIF::Archive::LookupKeys;
use strict;
use warnings;
use Mouse;
use namespace::autoclean;
use Data::Dumper;

has 'asn' => (
  is => 'ro',
  isa => 'ArrayRef[Int]',
  default => sub { [] },
  init_arg => undef,
  traits => ['Array'],
  handles => {
    map_asn => 'map',
    add_asn => 'push',
    asn_empty => 'is_empty'
  }
);

has 'cidr' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub { [] },
  init_arg => undef,
  traits => ['Array'],
  handles => {
    map_cidr => 'map',
    add_cidr => 'push',
    cidr_empty => 'is_empty'
  }
);

has 'email' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub { [] },
  init_arg => undef,
  traits => ['Array'],
  handles => {
    map_email => 'map',
    add_email=> 'push',
    email_empty => 'is_empty'
  }
);

has 'fqdn' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub { [] },
  init_arg => undef,
  traits => ['Array'],
  handles => {
    map_fqdn => 'map',
    add_fqdn => 'push',
    fqdn_empty => 'is_empty'
  }
);

has 'ip' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub { [] },
  init_arg => undef,
  traits => ['Array'],
  handles => {
    map_ip => 'map',
    add_ip => 'push',
    ip_empty => 'is_empty'
  }
);

has 'url' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub { [] },
  init_arg => undef,
  traits => ['Array'],
  handles => {
    map_url => 'map',
    add_url => 'push',
    url_empty => 'is_empty'
  }
);

sub is_empty {
  my $self = shift;
  return (
    $self->asn_empty() && $self->cidr_empty() && $self->email_empty() &&
    $self->fqdn_empty() && $self->ip_empty() && $self->url_empty()
  )
}

sub escape {
  my $val = shift;
  $val =~ s/"/\\"/g;
  return '"' . $val . '"';
}

sub buildit {
  my $arrayref = shift;
  return undef unless (@$arrayref);
  return('{' . join(',', (map { escape($_) } @$arrayref) ) . '}');
}

sub generate_hash {
  my $self = shift;
  return {
    asn => buildit($self->asn),
    cidr => buildit($self->cidr),
    email => buildit($self->email),
    fqdn => buildit($self->fqdn),
    ip => buildit($self->ip),
    url => buildit($self->url),
  };
}

__PACKAGE__->meta->make_immutable;
