package CIF::Router::Server;

use strict;
use warnings;
use AnyEvent;
use Coro;
use CIF::Router::Transport;
use Config::Simple;
use Try::Tiny;
use CIF::Codecs::JSON;
use Sys::Hostname;
use CIF::Router::Services::Query;
use CIF::Router::AuthenticatedRole;
use CIF::Router::Services::Submission;
use CIF::Router::Constants;
use CIF::Router::Services;
use CIF::DataStore::AnyEventFlusher;
use CIF::DataStore::Factory;
use CIF::Authentication::Factory;
use CIF::QueryHandler::Factory;

use CIF qw/debug init_logging generate_uuid_ns/;

sub new {
    my $class = shift;
    my $type = shift;
    my $config = shift;

    my $self = {};
    bless($self,$class);

    $self->{starttime} = time();
    $self->{type} = $type;
    my $services = CIF::Router::Services->new();
    my $service_class = $services->lookup($type);
    if (!defined($service_class)) {
      die("Unknown service type: $type");
    }
    $self->{service_class} = $service_class;
    $self->{codec} = CIF::Codecs::JSON->new();

    $self->{config} = Config::Simple->new($config) || die("Could not load config file: '$config'");
    $self->{server_config} = $self->{config}->param(-block => 'router_server');

    init_logging($self->{server_config}->{'debug'} || 0);

    my $driver_name = $self->{server_config}->{driver} || "RabbitMQ";
    my $driver_config = $self->{config}->param(-block => ('router_server_' . lc($driver_name)));
    my $driver_class = "CIF::Router::Transport::" . $driver_name;

    my $service_opts = {
      codec => $self->{codec}
    };

    if ($service_class->does("CIF::Router::AuthenticatedRole")) {
      my $auth_config = $self->{config}->get_block('auth');
      my $auth = CIF::Authentication::Factory->instantiate($auth_config);

      $service_opts->{auth} = $auth;
    }

    if ($service_class->does("CIF::Router::QueryHandlingRole")) {
      my $query_handler_config = $self->{config}->get_block('query_handler');
      my $query_handler = CIF::QueryHandler::Factory->instantiate($query_handler_config);

      $service_opts->{query_handler} = $query_handler;
    }

    if ($service_class->does("CIF::Router::DataSubmissionRole")) {
      my $datastore_config = $self->{config}->get_block('datastore');
      my $commit_interval = $datastore_config->{commit_interval} || 2;
      my $commit_size = $datastore_config->{commit_size} || 1000;
      $datastore_config->{flusher} = CIF::DataStore::AnyEventFlusher->new(
        commit_interval => $commit_interval,
        commit_size => $commit_size
      );

      $service_opts->{datastore} = CIF::DataStore::Factory->instantiate($datastore_config);
    }

    $self->{service} = $service_class->new(%$service_opts);

    $self->{control_service} = CIF::Router::Services::Control->new(
      codec => $self->{codec}
    );
    my $driver;
    my $err = shift;
    try {
      $driver = $driver_class->new($driver_config, $self->{service}, $self->{control_service});
    } catch {
      $err = shift;
      die "Driver ($driver_class) failed to load: $err";
    };

    $self->{driver} = $driver;

    return($self);
}

sub run {
    my $self = shift;

    $self->{driver}->start();

    $self->{cv} = AnyEvent->condvar;

    my $thr = async {
      $self->{cv}->recv();
      $self->{cv} = undef;
    };

    while ( defined( $self->{cv} ) ) {
      Coro::AnyEvent::sleep 1;
    }

    $self->{driver}->stop();
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

    if ($self->{service}) {
      $self->{service}->shutdown();
      delete $self->{service};
    }

    if ($self->{driver}) {
      $self->{driver}->shutdown();
      $self->{driver} = undef;
    }

}

1;
