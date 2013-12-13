package CIF::Router::Server;

use strict;
use warnings;
use AnyEvent;
use Coro;
use CIF::Router::Transport;
use Config::Simple;
use CIF::Router;
use Try::Tiny;
use CIF::Codecs::JSON;
use Sys::Hostname;
use CIF::Router::Services::Query;
use CIF::Router::Services::Submission;
use CIF::Router::Constants;
use CIF::Router::Services;
use CIF::DataStore::AnyEventFlusher;
use CIF::DataStore::Factory;
use CIF::Auth::Factory;

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

    my $datastore_config = $self->{config}->get_block('datastore');
    my $commit_interval = $datastore_config->{commit_interval} || 2;
    my $commit_size = $datastore_config->{commit_size} || 1000;
    $datastore_config->{flusher} = CIF::DataStore::AnyEventFlusher->new(
      commit_interval => $commit_interval,
      commit_size => $commit_size
    );

    my $datastore = CIF::DataStore::Factory->instantiate($datastore_config);

    my $auth_config = $self->{config}->get_block('auth');
    my $auth = CIF::Auth::Factory->instantiate($auth_config);

    # Initialize the router.
    my $router = CIF::Router->new({
        datastore => $datastore,
        auth => $auth
      });

    $self->{router} = $router;

    my $driver_name = $self->{server_config}->{driver} || "RabbitMQ";
    my $driver_config = $self->{config}->param(-block => ('router_server_' . lc($driver_name)));
    my $driver_class = "CIF::Router::Transport::" . $driver_name;

    $self->{service} = $service_class->new($self->{router}, $self->{codec});
    $self->{control_service} = CIF::Router::Services::Control->new($self->{router}, $self->{codec});
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

    if ($self->{driver}) {
      $self->{driver}->shutdown();
      $self->{driver} = undef;
    }

    if ($self->{router}) {
      $self->{router}->shutdown();
      $self->{router} = undef;
    }
}

1;
