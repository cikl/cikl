package CIF::Router::Transport;
use base 'Class::Accessor';

use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF qw/init_logging/;
use Module::Pluggable search_path => [__PACKAGE__], require => 1;
__PACKAGE__->plugins();

__PACKAGE__->follow_best_practice();

sub new {
    my $class = shift;
    my $config = shift;
    my $router = shift;
    my $type = shift;
    my $encoder = shift;
 
    my $self = { };
    bless($self,$class);

    $self->{router} = $router;
    $self->{config} = $config;
    $self->{type} = $type;
    $self->{encoder} = $encoder;

    return($self);
}

sub DESTROY {
    my $self = shift;
    $self->shutdown();
}

# This gets called before shutdown.
sub shutdown {
    my $self = shift;
    return(blessed($self) . " has not implemented the shutdown() method!");
}

sub type {
    my $self = shift;
    return $self->{type};
}

sub content_type {
    my $self = shift;
    return $self->{encoder}->content_type;
}

sub is_submission() {
    my $self = shift;
    return($self->{type} == CIF::Router::Server->SUBMISSION);
}

sub is_query() {
    my $self = shift;
    return($self->{type} == CIF::Router::Server->QUERY);
}

sub config {
    my $self = shift;
    my $opt = shift;
    return $self->{config}->{$opt};
}

sub submit_processor {
    my $class = shift;
    return $class->new(CIF::Router::Server->SUBMISSION);
}

sub query_processor {
    my $class = shift;
    return $class->new(CIF::Router::Server->QUERY);
}

sub process {
    my $self = shift;
    my $payload = shift;
    if ($self->is_submission()) {
      my $submission = $self->{encoder}->decode_submission($payload);
      return($self->{router}->process_submission($submission));
    } elsif ($self->is_query()) {
      my $query = $self->{encoder}->decode_query($payload);
      my $results = $self->{router}->process_query($query);
      return($self->{encoder}->encode_query_results($results));
    }
    return("Unknown mode");
}

sub run {
    my $self = shift;

    return(blessed($self) . " has not implemented the run() method!");
}

1;


