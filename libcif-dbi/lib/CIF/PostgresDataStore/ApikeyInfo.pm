package CIF::PostgresDataStore::ApikeyInfo;
use strict;
use warnings;
use Moose;
use namespace::autoclean;

has 'uuid' => (
  is => 'ro',
  required => 1
);

has 'default_guid' => (
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

has 'restricted_access' => (
  is => 'ro',
  isa => 'Bool',
  default => 0
);

has 'expires' => (
  is => 'ro',
  isa => 'Maybe[Int]'  # Epoch
);

has 'groups' => (
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
    ! $_[0]->restricted_access()
    && ! $_[0]->revoked()
    && ! $_[0]->is_expired()
  );
}

sub in_group {
  return $_[0]->groups->{$_[1]};
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
  my $key_info = shift;
  my $groups = shift;

  my $args = {
    uuid => $key_info->{uuid},
    revoked => $key_info->{revoked} || 0,
    write => $key_info->{write} || 0,
    restricted_access => $key_info->{restricted_access} || 0,
    groups => {}
  };

  if (my $expires = $key_info->{expires}) {
    $args->{expires} = DateTime::Format::DateParse->parse_datetime($expires)->epoch();
  }

  foreach my $guid (keys %{$groups}) {
    my $group = $groups->{$guid};
    if ($group->{default_guid}) {
      $args->{default_guid} = $guid;
    }
    $args->{groups}->{$guid} = 1;
  }

  return $class->new(%$args);
}

__PACKAGE__->meta->make_immutable();

1;
