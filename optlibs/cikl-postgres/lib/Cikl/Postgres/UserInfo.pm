package Cikl::Postgres::UserInfo;
use strict;
use warnings;
use Mouse;
use namespace::autoclean;

has 'apikey' => (
  is => 'ro',
  required => 1
);

has 'default_group_name' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'revoked' => (
  is => 'ro',
  isa => 'Bool',
  default => 0
);

has 'write' => (
  is => 'ro',
  isa => 'Bool',
  default => 0
);

has 'expires' => (
  is => 'ro',
  isa => 'Maybe[Int]'  # Epoch
);

has 'additional_groups' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { {} }
);

has 'in_good_standing' => (
  is => 'ro',
  lazy => 1,
  builder => '_build_in_good_standing'
);

sub _build_in_good_standing {
  return (
    ! $_[0]->revoked()
    && ! $_[0]->is_expired()
  );
}

sub in_group {
  my $self = shift;
  my $group_name = shift;
  return ($group_name eq $self->default_group_name) || 
    ($self->additional_groups->{$group_name});
}

sub is_expired {
  return (defined($_[0]->expires) && $_[0]->expires > time());
}

sub can_write {
  return ($_[0]->write && $_[0]->in_good_standing());
}

sub can_read {
  my $self = shift;
  return ($_[0]->in_good_standing());
}

sub from_db {
  my $class = shift;
  my $user_info = shift;

  my $args = {
    apikey => $user_info->{apikey},
    revoked => $user_info->{revoked},
    write => $user_info->{write},
    default_group_name => $user_info->{default_group_name},
    expires => $user_info->{expires},
    additional_groups => {
    }
  };

  if (defined($user_info->{additional_groups})) {
    foreach my $group (@{$user_info->{additional_groups}}) {
      $args->{additional_groups}->{$group} = 1;
    }
  }

  return $class->new(%$args);
}

__PACKAGE__->meta->make_immutable();

1;

