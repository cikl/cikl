package CIF::Client::Transport::Direct;
use base 'CIF::Client::Transport';

use strict;
use warnings;
use CIF::Router;
use CIF::DataStore::SimpleFlusher;
use CIF::DataStore::Factory;
use CIF::Authentication::Factory;
use CIF qw/debug/;
use Time::HiRes qw/gettimeofday tv_interval/;

sub new {
    my $class = shift;
    my $args = shift;
    $args->{driver_name} = "direct";
    my $self = $class->SUPER::new($args);

    my $last_flush = [gettimeofday];

    my $datastore_config = $self->get_global_config()->get_block('datastore');
    my $auth_config = $self->get_global_config()->get_block('auth');

    my $flusher = CIF::DataStore::SimpleFlusher->new(
      commit_interval => $datastore_config->{commit_interval} || 2,
      commit_size => $datastore_config->{commit_size} || 1000);

    $datastore_config->{flusher} = $flusher;
    my $datastore = CIF::DataStore::Factory->instantiate($datastore_config);
    my $auth = CIF::Authentication::Factory->instantiate($auth_config);

    $self->{router} = CIF::Router->new({
      datastore => $datastore,
      auth => $auth
    });

    return $self;
}

sub shutdown {
    my $self = shift;
    if (!$self->SUPER::shutdown()) {
      # We've already shutdown.
      return 0;
    }

    if ($self->{router}) {
      $self->{router}->shutdown();
      $self->{router} = undef;
    }
    return 1;
}

sub query {
    my $self = shift;
    my $query = shift;
    return $self->{router}->process_query($query);
}

sub ping {
    my $self = shift;
    my $hostinfo = shift;
}

sub submit {
    my $self = shift;
    my $submission = shift;
    return $self->{router}->process_submission($submission);
}

1;
