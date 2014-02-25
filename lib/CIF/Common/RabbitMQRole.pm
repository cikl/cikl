package CIF::Common::RabbitMQRole;
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
  default => '/cif'
);

has 'submit_key' => (
  is => 'ro', 
  isa => 'Str',
  default => 'submission.new'
);

has 'submit_exchange' => (
  is => 'ro', 
  isa => 'Str',
  default => 'cif.submission'
);

has 'postprocess_key' => (
  is => 'ro', 
  isa => 'Str',
  default => 'submission.postprocess'
);

has 'postprocess_exchange' => (
  is => 'ro', 
  isa => 'Str',
  default => 'cif.submission'
);

has 'query_key' => (
  is => 'ro', 
  isa => 'Str',
  default => 'query'
);

has 'query_exchange' => (
  is => 'ro', 
  isa => 'Str',
  default => 'cif.query'
);

has 'control_key' => (
  is => 'ro', 
  isa => 'Str',
  default => 'service.control'
);

has 'control_exchange' => (
  is => 'ro', 
  isa => 'Str',
  default => 'cif.service'
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
