package CIF::Client::Transport;
use base 'Class::Accessor';

use strict;
use warnings;
use Scalar::Util qw(blessed);

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(qw(config));

sub new {
    my $class = shift;
    my $args = shift;
 
    my $self = { };
    bless($self,$class);

    $self->set_config($args->{'config'});
    return($self);
}

sub query {
    my $self = shift;
    my $queries = shift;

    return(blessed($self) . " has not implemented the send_query() method!");
}

sub submit {
    my $self = shift;
    my $apikey = shift;
    my $guid = shift;
    my $iodefs = shift;

    return(blessed($self) . " has not implemented the send_submission() method!");
}

1;

