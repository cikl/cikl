package CIF::Client::Transport::Direct;
use base 'CIF::Client::Transport';

use strict;
use warnings;
use CIF::Util::Flusher;
use CIF::DataStore::Factory;
use CIF::Authentication::Factory;
use CIF::QueryHandler::Factory;
use CIF qw/debug/;
use Time::HiRes qw/gettimeofday tv_interval/;

sub new {
    my $class = shift;
    my $args = shift;
    $args->{driver_name} = "direct";
    my $self = $class->SUPER::new($args);

    my $last_flush = [gettimeofday];

    my $datastore_config = $self->get_global_config()->get_block('datastore');

    $self->{datastore} = CIF::DataStore::Factory->instantiate($datastore_config);
    my $flusher = CIF::Util::Flusher->new(
      flushable => $self->{datastore},
      commit_interval => $datastore_config->{commit_interval} || 2,
      commit_size => $datastore_config->{commit_size} || 1000);
    $self->{flusher} = $flusher;

    my $auth_config = $self->get_global_config()->get_block('auth');
    $self->{auth} = CIF::Authentication::Factory->instantiate($auth_config);

    my $query_handler_config = $self->get_global_config()->get_block('query_handler');
    $self->{query_handler} = CIF::QueryHandler::Factory->instantiate($query_handler_config);

    return $self;
}

sub shutdown {
    my $self = shift;
    if (!$self->SUPER::shutdown()) {
      # We've already shutdown.
      return 0;
    }

    $self->{flusher}->flush();
    $self->{flusher} = undef;

    foreach my $service (qw/auth query_handler datastore/) {
      if ($self->{$service}) {
        $self->{$service}->shutdown();
        $self->{$service} = undef;
      }
    }
    return 1;
}

sub query {
    my $self = shift;
    my $query = shift;

    my $apikey_info = $self->{auth}->authorized_read(
      $query->apikey, $query->group());

    if (!defined($query->group())) {
      $query->group($apikey_info->{'default_group'});
    }
    return $self->{query_handler}->search($query);
}

sub ping {
    my $self = shift;
    my $hostinfo = shift;
}

sub submit {
    my $self = shift;
    my $submission = shift;
    my $group = $submission->event->group();
    my $apikey = $submission->apikey();
    my $auth = $self->{auth}->authorized_write($apikey, $group);

    if (!$auth) {
      die("apikey '$apikey' is not authorized to write for group '$group'");
    }
    $self->{datastore}->submit($submission);
    $self->{flusher}->tick();
    return undef;
}

1;
