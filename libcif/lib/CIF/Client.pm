package CIF::Client;
use base 'Class::Accessor';

use strict;
use warnings;
use Data::Dumper;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];
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
    nolog limit guid filter_me no_maprestrictions
    table_nowarning related
));

our @queries = __PACKAGE__->plugins();
@queries = map { $_ =~ /::Query::/ } @queries;

sub new {
    my $class = shift;
    my $args = shift;
    
    return('missing config file') unless($args->{'config'});
    
    $args->{'config'} = Config::Simple->new($args->{'config'}) || return('missing config file');
    
    my $self = {};
    bless($self,$class);
    
    $self->set_global_config(   $args->{'config'});
    $self->set_config(          $args->{'config'}->param(-block => 'client'));
    $self->set_apikey(          $args->{'apikey'} || $self->get_config->{'apikey'});
    
    $self->{'guid'}             = $args->{'guid'}               || $self->get_config->{'default_guid'};
    $self->{'limit'}            = $args->{'limit'}              || $self->get_config->{'limit'};
    $self->{'compress_address'} = $args->{'compress_address'}   || $self->get_config->{'compress_address'};
    $self->{'round_confidence'} = $args->{'round_confidence'}   || $self->get_config->{'round_confidence'};
    $self->{'table_nowarning'}  = $args->{'table_nowarning'}    || $self->get_config->{'table_nowarning'};
    
    $self->{'group_map'}        = (defined($args->{'group_map'})) ? $args->{'group_map'} : $self->get_config->{'group_map'};
    
    $self->set_no_maprestrictions(  $args->{'no_maprestrictions'}   || $self->get_config->{'no_maprestrictions'});
    $self->set_filter_me(           $args->{'filter_me'}            || $self->get_config->{'filter_me'});
    $self->set_nolog(               $args->{'nolog'}                || $self->get_config->{'nolog'});
    $self->set_related(             $args->{'related'}              || $self->get_config->{'related'});
    
    my $nolog = (defined($args->{'nolog'})) ? $args->{'nolog'} : $self->get_config->{'nolog'};
    
    if($args->{'fields'}){
        @{$self->{'fields'}} = split(/,/,$args->{'fields'}); 
    } 
    
    my $err = $self->_init_driver($self->get_config->{'driver'} || 'RabbitMQ');
    return($err) if ($err);

    return (undef,$self);
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
    my $err;
    my $driver;
    try {
        $driver     = $driver_class->new({
            config => $self->get_global_config()
        });
    } catch {
        $err = shift;
    };
    if($err){
        debug($err) if($::debug);
        return($err);
    }
    
    $self->{driver} = $driver;
    return undef;
}

sub search {
    my $self = shift;
    my $query = shift;
    my $args = shift;
    
    my $err;
    my $orig_query = $query;
    # make sure if there are no spaces between queries
    $query =~ s/\s//g;

    my @orig_queries = split(/,/,$query);

    my $filter_me   = $args->{'filter_me'} || $self->get_filter_me();
    my $nolog       = (defined($args->{'nolog'})) ? $args->{'nolog'} : $self->get_nolog();

    unless($args->{'apikey'}){
        $args->{'apikey'} = $self->get_apikey();
    }

    my @queries;
    
    # we have to pass this along so we can check it later in the code
    # for our original queries since the server will give us back more 
    # than we asked for
    my $ip_tree = Net::Patricia->new();
    
    my $query_model;
    try {
      $query_model = CIF::Models::Query->new(
        {
          apikey      => $args->{'apikey'},
          guid        => $args->{'guid'},
          query       => $orig_query,
          nolog       => $nolog,
          limit       => $args->{'limit'},
          confidence  => $args->{'confidence'},
          description => $args->{'description'},
        }
      );
    } catch {
      $err = $_;
    };

    if (!defined($query_model)) {
      return("Failed to create query object: $err");
    }

    my $query_results;
    try {
      $query_results = $self->get_driver->query($query_model);
    } catch {
      $err = shift;
    };
    return $err if($err);

    return(undef,$query_results);
}

sub send {
    my $self = shift;
    my $msg = shift;
    
    return $self->get_driver->send($msg);
}

sub send_json {
    my $self = shift;
    my $msg = shift;
 
    return $self->get_driver->send_json({
        data    => $msg,
        apikey  => $self->get_apikey(),
    });   
}

sub submit {
    my $self = shift;
    my $guid = shift;
    my $event = shift;

    my $submission = CIF::Models::Submission->new($self->get_apikey(), $guid, $event);
    return $self->get_driver()->submit($submission);
}    

sub ping {
    my $self = shift;

    my $hostinfo = CIF::Models::HostInfo->generate({uptime => 0});

    return $self->get_driver()->ping($hostinfo);
}    

# confor($conf, ['infrastructure/botnet', 'client'], 'massively_cool_output', 0)
#
# search the given sections, in order, for the given config param. if found, 
# return its value or the default one specified.

sub confor {
    my $conf = shift;
    my $sections = shift;
    my $name = shift;
    my $def = shift;

    # return unless we get called with a config (eg: via the WebAPI)
    return unless($conf->{'config'});

    # handle
    # snort_foo = 1,2,3
    # snort_foo = "1,2,3"

    foreach my $s (@$sections) { 
        my $sec = $conf->{'config'}->param(-block => $s);
        next if isempty($sec);
        next if !exists $sec->{$name};
        if (defined($sec->{$name})) {
            return ref($sec->{$name} eq "ARRAY") ? join(', ', @{$sec->{$name}}) : $sec->{$name};
        } else {
            return $def;
        }
    }
    return $def;
}

sub isempty {
    my $h = shift;
    return 1 unless ref($h) eq "HASH";
    my @k = keys %$h;
    return 1 if $#k == -1;
    return 0;
}

1;
