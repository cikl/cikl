package CIF::Router::Server;

use strict;
use warnings;
use AnyEvent;
use Coro;
use Coro::AnyEvent;
use CIF::Router::Transport;
use CIF::Router::ServiceRole;
use Config::Simple;
use Mouse;
use namespace::autoclean;
use CIF qw/init_logging/;

use CIF qw/debug init_logging generate_uuid_ns/;

has 'service' => (
  is => 'ro',
  isa => 'CIF::Router::ServiceRole',
  required => 1
);

has 'control_service' => (
  is => 'ro',
  isa => 'CIF::Router::Services::Control',
  required => 1
);

has 'transport' => (
  is => 'ro',
  isa => 'CIF::Router::Transport',
  required => 1,
);

has 'config' => (
  is => 'ro',
  isa => 'Config::Simple',
  required => 1
);

has 'starttime' => (
  is => 'ro',
  isa => 'Num',
  init_arg => undef,
  default => sub {time()}
);

sub BUILD {
  my $self = shift;
  my $router_config = $self->config->block('router');
  init_logging($router_config->{'debug'} || 0);
}

sub run {
  my $self = shift;

  $self->transport->start();

  $self->{cv} = AnyEvent->condvar;

  my $checkpoint_timer = AnyEvent->timer(
    after => 0.1,
    interval => 0.1,
    cb => sub {
      $self->service->checkpoint();
      $self->control_service->checkpoint();
    }
  );

  my $thr = async {
    $self->{cv}->recv();
    $self->{cv} = undef;
  };

  while ( defined( $self->{cv} ) ) {
    Coro::AnyEvent::sleep 1;
  }

  $self->transport->stop();
}

sub stop {
  my $self = shift;
  if (my $cv = $self->{cv}) {
    debug("Stopping");
    $cv->send(undef);
  }
}

sub shutdown {
  my $self = shift;
  $self->service->shutdown();
  $self->control_service->shutdown();
  $self->transport->shutdown();
}

__PACKAGE__->meta->make_immutable();
1;
