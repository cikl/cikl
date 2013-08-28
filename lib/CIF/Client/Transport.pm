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

sub send {
    my $self = shift;
    my $data = shift;

    return(blessed($self) . " has not implemented the send() method!");
}

1;

