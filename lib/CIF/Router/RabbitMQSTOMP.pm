package CIF::Router::RabbitMQSTOMP;

use strict;
use warnings;

## TODO -- split this out in CIF v2
## leaving it here for now, simplier

require CIF::Router;
require CIF::Router::HTTP::Json;
use CIF qw/init_logging/;
use Data::Dumper;
use Net::STOMP::Client;

## NOTE: we do it this way cause mod_perl calls us by name
## not CIF::Router
## required by ::Router
sub new {
    my $class = shift;
    my $id = shift;
    my $dest = shift;
    my $persist = shift || 0;
    my $self = {};
    bless($self,$class);

    my $config = "/home/mryan/code/cif-v1-dev/cif.conf";

    my ($err,$router) = CIF::Router->new({
        config  => $config,
      });
    if($err){
      ## TODO -- set debugging variable
      die $err;
    }
    $self->{router} = $router;

    my $debug = $router->get_config->{'debug'} || 0;

    init_logging($debug);

    my $stomp = Net::STOMP::Client->new(uri => "stomp://localhost:61613/");
    $stomp->connect(login => "guest", passcode => "guest", "host" => "/");

    my $subscribe_opts = {
      destination => $dest, 
      "id" => $id, 
      persistent => $persist
    };
    $stomp->subscribe(
      %$subscribe_opts
    );

    $self->{stomp} = $stomp;

    return($self);
}

sub run {
    my $self = shift;

    while (my $frame = $self->{stomp}->wait_for_frames()) {
      next unless ($frame->command() eq "MESSAGE");
      my $body = $frame->body;
      my $reply = $self->{router}->process($body);
      if (my $reply_queue = $frame->header('reply-to')) {
        $self->{stomp}->send(destination => $reply_queue, body => $reply);
      }
    }
}

1;

