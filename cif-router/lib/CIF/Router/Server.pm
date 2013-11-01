package CIF::Router::Server;

use strict;
use warnings;
use CIF::Router::Transport;
use Config::Simple;
use CIF::Router;
use Try::Tiny;
use CIF::Encoder::JSON;

use CIF qw/init_logging/;


#  CIF::Router::Transport->QUERY
#  CIF::Router::Transport->SUBMISSION

sub new {
    my $class = shift;
    my $type = shift;
    my $config = shift;

    my $self = {};
    bless($self,$class);

    $self->{config} = Config::Simple->new($config) || die("Could not load config file: '$config'");
    $self->{server_config} = $self->{config}->param(-block => 'router_server');

    $self->{encoder} = CIF::Encoder::JSON->new();

    init_logging($self->{server_config}->{'debug'} || 0);

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

sub shutdown {
    my $self = shift;
    if ($self->{driver}) {
      $self->{driver}->shutdown();
      $self->{driver} = undef;
    }
}

1;
