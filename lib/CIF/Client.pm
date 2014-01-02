package CIF::Client;
use base 'Class::Accessor';

use strict;
use warnings;
use Try::Tiny;
use Config::Simple;
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;
use Net::Patricia;
use URI::Escape;
use Digest::MD5 qw/md5_hex/;
use Encode qw(encode_utf8);
use CIF::Models::Submission;
use CIF::Models::Query;
use CIF::Models::HostInfo;

use CIF qw(generate_uuid_ns generate_uuid_random is_uuid debug);

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(qw(
    config global_config apikey 
    nolog limit group 
));

sub new {
    my $class = shift;
    my $args = shift;
    
    die('missing config') unless($args->{'config'});
    
    my $self = {};
    bless($self,$class);
    
    $self->set_global_config(   $args->{'config'});
    $self->set_config(          $args->{'config'}->param(-block => 'client'));
    $self->set_apikey(          $args->{'apikey'} || $self->get_config->{'apikey'});
    
    $self->{'group'}             = $args->{'group'}               || $self->get_config->{'default_group'};
    $self->{'limit'}            = $args->{'limit'}              || $self->get_config->{'limit'};
    
    $self->set_nolog(               $args->{'nolog'}                || $self->get_config->{'nolog'});
    
    my $nolog = (defined($args->{'nolog'})) ? $args->{'nolog'} : $self->get_config->{'nolog'};
    
    if($args->{'fields'}){
        @{$self->{'fields'}} = split(/,/,$args->{'fields'}); 
    } 
    
    $self->{driver} = $self->_init_driver($self->get_config->{'driver'} || 'RabbitMQ');

    return $self;
}

sub DESTROY {
    my $self = shift;
    $self->shutdown();
}

sub shutdown {
    my $self = shift;
    if ($self->{driver}) {
      $self->{driver}->shutdown();
      $self->{driver} = undef;
    }
    return 1;
}

sub get_driver {
    my $self = shift;
    if ($self->{driver}) {
      return $self->{driver};
    }
    die("The driver has already been shutdown!");
}


sub _init_driver {
    my $self = shift;
    my $driver_name = shift;
    my $driver_class     = 'CIF::Client::Transport::'.$driver_name;
    eval("use $driver_class;");
    if ($@) {
      die($@);
    }
    my $driver     = $driver_class->new({
            config => $self->get_global_config()
        });
    
    return $driver;
}

sub query {
    my $self = shift;
    my %args = @_;

    $args{nolog} //= $self->get_nolog();
    $args{limit} //= $self->get_limit();
    $args{apikey} //= $self->get_apikey();

    if (my $group = $args{group}) {
      $args{group} = $group;
    }

    my $err;
    my $query;
    
    try {
      $query = CIF::Models::Query->new(%args);
    } catch {
      $err = $_;
    };

    if (!defined($query)) {
      die("Failed to create query object: $err");
    }

    my $query_results = $self->get_driver->query($query);

    return($query_results);
}

sub submit {
    my $self = shift;
    my $event = shift;

    my $submission = CIF::Models::Submission->new(
      apikey => $self->get_apikey(), 
      event => $event
    );
    return $self->get_driver()->submit($submission);
}    

sub ping {
    my $self = shift;

    my $hostinfo = CIF::Models::HostInfo->generate({uptime => 0, service_type => 'client'});

    return $self->get_driver()->ping($hostinfo);
}    

1;
