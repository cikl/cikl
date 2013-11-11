package CIF::Router::Transport;

use strict;
use warnings;
use Scalar::Util qw(blessed);
use Module::Pluggable search_path => [__PACKAGE__], require => 1;
__PACKAGE__->plugins();

sub new {
    my $class = shift;
    my $config = shift;
 
    my $self = { };
    bless($self,$class);

    $self->{config} = $config;

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


