package Cikl::Common::RabbitMQRole;
use strict;
use warnings;

use Mouse::Role;
use namespace::autoclean;
require Net::RabbitFoot;

has 'host' => (
  is => 'ro',
  isa => 'Str',
  default => 'localhost'
);

has 'port' => (
  is => 'ro',
  isa => 'Num',
  default => 5572
);

has 'username' => (
  is => 'ro',
  isa => 'Str',
  default => 'guest'
);

has 'password' => (
  is => 'ro',
  isa => 'Str',
  default => 'guest'
);

has 'vhost' => (
  is => 'ro',
  isa => 'Str',
  default => '/'
);

has 'submit_key' => (
  is => 'ro', 
  isa => 'Str',
  default => 'cikl.event'
);

has 'submit_exchange' => (
  is => 'ro', 
  isa => 'Str',
  default => ''
);

has 'amqp' => (
  is => 'ro', 
  isa => 'Net::RabbitFoot',
  init_arg => undef,
  lazy_build => 1
);

sub _build_amqp {
  my $self = shift;
  return Net::RabbitFoot->new()->load_xml_spec()->connect(
    host => $self->host(),
    port => $self->port(),
    user => $self->username(),
    pass => $self->password(),
    vhost => $self->vhost()
  );
}

sub shutdown_amqp {
  my $self = shift;

  if ($self->has_amqp()) {
    $self->amqp->close();
    $self->clear_amqp();
  }
}

1;
