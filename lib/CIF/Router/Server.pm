package CIF::Router::Server;

use strict;
use warnings;
use CIF::Router::Transport;
use Config::Simple;
use CIF::Router;
use Try::Tiny;
use CIF::Encoder::JSON;

use CIF qw/init_logging/;

sub new {
    my $class = shift;
    my $type = shift;

    my $self = {};
    bless($self,$class);

    my $config = "/home/mryan/code/cif-v1-dev/cif.conf";
    $self->{config} = Config::Simple->new($config);
    $self->{server_config} = $self->{config}->param(-block => 'router_server');

    $self->{encoder} = CIF::Encoder::JSON->new();

    init_logging($self->{config}->{'debug'} || 0);

    # Initialize the router.
    my ($err,$router) = CIF::Router->new({
        config  => $self->{config},
      });
    if($err){
      ## TODO -- set debugging variable
      die $err;
    }

    my $driver_name = $self->{server_config}->{driver} || "RabbitMQ";
    my $driver_config = $self->{config}->param(-block => ('router_server_' . lc($driver_name)));
    my $driver_class = "CIF::Router::Transport::" . $driver_name;

    my $driver;
    try {
      $driver = $driver_class->new($driver_config, $router, $type, $self->{encoder});
    } catch {
      $err = shift;
      die "Driver ($driver_class) failed to load: $err";
    };

    $self->{driver} = $driver;

    return($self);
}

sub run() {
    my $self = shift;
    $self->{driver}->run();
}

sub run_query_server {
    my $class = shift;
    $class->new(CIF::Router::Transport->QUERY)->run();
}

sub run_submit_server {
    my $class = shift;
    $class->new(CIF::Router::Transport->SUBMISSION)->run();
}

1;



