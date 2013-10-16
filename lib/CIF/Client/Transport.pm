package CIF::Client::Transport;
use base 'Class::Accessor';

use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF::Encoder::Legacy;

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(qw(config global_config));

sub new {
    my $class = shift;
    my $args = shift;
 
    my $self = { };
    bless($self,$class);

    my $global_config = $args->{'config'};
    my $driver_config = $global_config->param(-block => 'client_'.$args->{driver_name});

    $self->{encoder} = CIF::Encoder::Legacy->new();
    $self->set_config($driver_config);
    $self->set_global_config($global_config);
    return($self);
}

sub query {
    my $self = shift;
    my $queries = shift;

    return(blessed($self) . " has not implemented the query() method!");
}

sub submit {
    my $self = shift;
    my $apikey = shift;
    my $guid = shift;
    my $events = shift;

    my @uuids;
    foreach my $event (@$events) {
      push(@uuids, $event->{id});
      $self->submit_event($apikey, $guid, $event);
    }

    return (undef, \@uuids);
}


sub submit_event {
    my $self = shift;
    my $apikey = shift;
    my $guid = shift;
    my $event = shift;

    return(blessed($self) . " has not implemented the submit_event() method!");
}

1;

