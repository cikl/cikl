package Cikl::Router::ServerFactory;
use strict;
use warnings;
use Cikl::Authentication::Factory;
use Cikl::Codecs::JSON;
use Cikl::DataStore::Factory;
use Cikl::QueryHandler::Factory;
use Cikl::Router::Server;
use Cikl::Router::Services;
use Cikl::Router::Transport;
use Config::Simple;

sub instantiate {
  my $class = shift;
  my $type = shift;
  my $config_file = shift;

  my $config = Config::Simple->new($config_file) || die("Could not load config file: '$config_file'");
  my $services = Cikl::Router::Services->new();
  my $service_class = $services->lookup($type);
  if (!defined($service_class)) {
    die("Unknown service type: $type");
  }

  my $codec = Cikl::Codecs::JSON->new();

  my $service_opts = {
    codec => $codec
  };

  if ($service_class->does("Cikl::Router::AuthenticatedRole")) {
    my $auth_config = $config->get_block('auth');
    my $auth = Cikl::Authentication::Factory->instantiate($auth_config);

    $service_opts->{auth} = $auth;
  }

  if ($service_class->does("Cikl::Router::QueryHandlingRole")) {
    my $query_handler_config = $config->get_block('query_handler');
    my $query_handler = Cikl::QueryHandler::Factory->instantiate($query_handler_config);

    $service_opts->{query_handler} = $query_handler;
  }

  if ($service_class->does("Cikl::Router::DataSubmissionRole")) {
    my $datastore_config = $config->get_block('datastore');
    my $commit_interval = $datastore_config->{commit_interval} || 2;
    my $commit_size = $datastore_config->{commit_size} || 1000;
    my $datastore = Cikl::DataStore::Factory->instantiate($datastore_config);
    $service_opts->{datastore} = $datastore;
  }

  my $service = $service_class->new(%$service_opts);

  my $control_service = Cikl::Router::Services::Control->new(
    codec => $codec
  );

  my $transport = build_transport($config);
  $transport->register_service($service);
  $transport->register_service($control_service);
  #$transport->register_control_service($control_service);

  return Cikl::Router::Server->new(
    service => $service,
    control_service => $control_service,
    config => $config,
    transport => $transport
  );
}

sub build_transport {
  my $config = shift;
  my $service = shift;
  my $control_service = shift;
  my $server_config = $config->param(-block => 'router_server');
  my $driver_name = $server_config->{driver} || "RabbitMQ";
  my $driver_config = $config->param(-block => ('router_server_' . lc($driver_name)));
  my $driver_class = "Cikl::Router::Transport::" . $driver_name;
  eval "use $driver_class;";
  if ($@) { 
    die $@; 
  }
  return $driver_class->new(%$driver_config);
}


1;

