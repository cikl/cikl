package CIF::Client;
use base 'Class::Accessor';

use strict;
use warnings;
use Data::Dumper;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];
use Try::Tiny;
use Config::Simple;
use Digest::SHA qw/sha1_hex/;
use Iodef::Pb::Simple qw/iodef_addresses iodef_confidence iodef_impacts/;
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;
use Net::Patricia;
use URI::Escape;
use Digest::MD5 qw/md5_hex/;
use Encode qw(encode_utf8);
use CIF::Models::Submission;
use CIF::Models::Query;

use CIF qw(generate_uuid_ns generate_uuid_random is_uuid debug);
use CIF::Msg;
use CIF::Msg::Feed;

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(qw(
    config global_config driver apikey 
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
    
    $self->set_driver($driver);
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

    my $dt = DateTime->from_epoch(epoch => $query_results->reporttime);
    my @res;
    foreach my $event (@{$query_results->events}) {
      my $iodef = Iodef::Pb::Simple->new($event);
      push (@res, $iodef);
    }
    $dt = $dt->ymd().'T'.$dt->hms().'Z';

    my $f = FeedType->new({
        version         => $CIF::VERSION,
        confidence      => $query_results->query->confidence(),
        description     => $query_results->query->description(),
        ReportTime      => $dt,
        group_map       => $query_results->group_map, # so they can't see other groups they're not in
        restriction_map => $query_results->restriction_map,
        data            => \@res,
        uuid            => $query_results->uuid,
        guid            => $query_results->guid,
        query_limit     => $query_results->query_limit,
        # todo -- make this avail to to libcif
        # https://github.com/collectiveintel/cif-router/issues/5
        #feeds_map       => $self->get_feeds_map(),
      });  
    
 
    my $uuid = generate_uuid_ns($args->{'apikey'});
    my $feeds = [ $f ];
    filter_response($feeds, $uuid, $filter_me, $ip_tree, \@orig_queries);
    
    debug('done processing');
    return(undef,$feeds);
}

sub filter_response {
    my $feeds = shift; 
    my $uuid = shift;
    my $filter_me = shift;
    my $ip_tree = shift;
    my $orig_queries = shift;

    my $query_had_ips = $ip_tree->climb();
    my @ip_queries;
    foreach my $q (@$orig_queries) {
      next unless ($q =~ /^$RE{'net'}{'IPv4'}/);
      push(@ip_queries, $q);
    }
    debug('filtering...') if($::debug);
    ## TODO: finish this so feeds are inline with reg queries
    ## TODO: try to base64 decode and decompress first in try { } catch;
    foreach my $feed (@{$feeds}){
        my @array;
        my $err = undef;

        next unless($feed->get_data());

        debug('processing: '.($#{$feed->get_data}+1).' items') if($::debug);
        foreach my $e (@{$feed->get_data()}){
            if($filter_me){
                my $id = @{$e->get_Incident()}[0]->get_IncidentID->get_name();
                # filter out my searches
                next if($id eq $uuid);
            }
            if($query_had_ips){
                next unless(ip_in_scope($uuid, $ip_tree, $e, \@ip_queries));
            }
            push(@array,$e);
        }

        if($#array > -1){
            debug('final results: '.($#array+1)) if($::debug);
            $feed->set_data(\@array);
        } else {
            $feed->set_data(undef);
        }
    }
}

sub ip_in_scope {
    my $uuid = shift;
    my $ip_tree = shift;
    my $iodef = shift;
    my $ip_queries = shift;

    my $addresses = iodef_addresses($iodef);

    # if there are no addresses, we've got nothing or hashes
    unless (@$addresses) {
      return 1;
    }

    foreach my $a (@$addresses) {
      next unless ($a->get_content =~ /^$RE{'net'}{'IPv4'}/);               
      # if we have a match great
      # if we don't we need to test and see if this address
      # contains our original query
      if ($ip_tree->match_string($a->get_content())){
        return 1;
      } 

      my $ip_tree2 = Net::Patricia->new();
      $ip_tree2->add_string($a->get_content());
      foreach my $ip (@$ip_queries){
        if($ip_tree2->match_string($ip)){
          return 1;
        }
      }
    }

    return 1;
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

sub send_keypairs {
    my $self = shift;
    my $args = shift;
    
    my $guid = $args->{'guid'} || 'everyone';
    my $data = $args->{'data'};
    
    return unless(ref($data) eq 'ARRAY' || ref($data) eq 'HASH');
    $data = [$data] unless(ref($data) eq 'ARRAY');
    
    foreach (@$data){
        unless(exists($_->{'id'})){
            $_->{'id'} = generate_uuid_random();
        }
        $_ = Iodef::Pb::Simple->new($_);
    }
 
    return $self->submit($guid, $data);
}
    
sub submit {
    my $self = shift;
    my $guid = shift;
    my $event = shift;

    my $submission = CIF::Models::Submission->new($self->get_apikey(), $guid, $event);
    return $self->get_driver()->submit($submission);
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
