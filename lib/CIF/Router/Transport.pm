package CIF::Router::Transport;

use strict;
use warnings;
use Scalar::Util qw(blessed);
use Carp;

sub new {
    my $class = shift;
    my $config = shift;
    my $service = shift;
    my $control_service = shift;
 
    my $self = { };
    bless($self,$class);

    $self->{config} = $config;
    $self->{service} = $service;
    $self->{control_service} = $control_service;

    return($self);
}

sub DESTROY {
    my $self = shift;
    $self->shutdown();
}

sub config {
    my $self = shift;
    my $opt = shift;
    return $self->{config}->{$opt};
}

sub service {
    my $self = shift;
    return $self->{service};
}

sub control_service {
    my $self = shift;
    return $self->{control_service};
}

# This gets called before shutdown.
sub shutdown {
    my $self = shift;
    return(blessed($self) . " has not implemented the shutdown() method!");
}

sub setup_ping_processor {
    my $self = shift;
    my $payload_callback = shift;
    return(blessed($self) . " has not implemented the setup_ping_processor() method!");
}

sub setup_query_processor {
    my $self = shift;
    my $payload_callback = shift;
    return(blessed($self) . " has not implemented the setup_query_processor() method!");
}

sub setup_submission_processor {
    my $self = shift;
    my $payload_callback = shift;
    return(blessed($self) . " has not implemented the setup_submission_processor() method!");
}

sub run {
    my $self = shift;
    return(blessed($self) . " has not implemented the run() method!");
}

1;


