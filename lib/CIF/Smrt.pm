package CIF::Smrt;
use base 'Class::Accessor';

use 5.008008;
use strict;
use warnings;
use threads;

our $VERSION = '0.99_03';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# default severity mapping
use constant DEFAULT_SEVERITY_MAP => {
    botnet      => 'high',
};

use CIF::Client;
use Regexp::Common qw/net URI/;
use Regexp::Common::net::CIDR;
use Encode qw/encode_utf8/;
use Data::Dumper;
use File::Type;
use Module::Pluggable require => 1;
use Digest::SHA qw/sha1_hex/;
use URI::Escape;
use Try::Tiny;

use Net::SSLeay;
Net::SSLeay::SSLeay_add_ssl_algorithms();

use CIF qw/generate_uuid_url generate_uuid_random is_uuid debug normalize_timestamp/;

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(qw(
    config feeds_config feeds threads 
    entries defaults feed rules load_full goback 
    client wait_for_server name instance 
    batch_control client_config apikey
    severity_map proxy
));

my @preprocessors = __PACKAGE__->plugins();
@preprocessors = grep(/Preprocessor::[0-9a-zA-Z_]+$/,@preprocessors);

sub new {
    my $class = shift;
    my $args = shift;
    
    my $self = {};
    bless($self,$class);
      
    my ($err,$ret) = $self->init($args);
    return($err) if($err);

    return (undef,$self);
}

sub init {
    my $self = shift;
    my $args = shift;

    my ($err,$ret) = $self->init_config($args);
    return($err) if($err);
      
    ($err,$ret) = $self->init_rules($args);
    return($err) if($err);

    $self->set_goback(          $args->{'goback'}           || $self->get_config->{'goback'}            || 3);
    $self->set_wait_for_server( $args->{'wait_for_server'}  || $self->get_config->{'wait_for_server'}   || 0);
    $self->set_batch_control(   $args->{'batch_control'}    || $self->get_config->{'batch_control'}     || 2500); # arbitrary
    $self->set_apikey(          $args->{'apikey'}           || $self->get_config->{'apikey'}            || return('missing apikey'));
    $self->set_proxy(           $args->{'proxy'}            || $self->get_config->{'proxy'});
   
    $self->set_goback(time() - ($self->get_goback() * 84600));
    
    if($::debug){
        my $gb = DateTime->from_epoch(epoch => $self->get_goback());
        debug('goback: '.$gb);
    }    
    
    ## TODO -- this isnt' being passed to the plugins, the config is
    $self->set_name(        $args->{'name'}     || $self->get_config->{'name'}      || 'localhost');
    $self->set_instance(    $args->{'instance'} || $self->get_config->{'instance'}  || 'localhost');
    
    $self->init_feeds($args);

    my ($err2,$client) = CIF::Client->new({
        config  => $self->get_client_config(),
        apikey  => $self->get_apikey(),
    });
    $self->set_client($client);

    return($err,$ret) if($err);
    return(undef,1);
}

sub init_config {
    my $self = shift;
    my $args = shift;
    
    # do this here, we'll do the setup within the sender_routine (thread)
    $self->set_client_config($args->{'config'});
    
    my $err;
    try {
        $args->{'config'} = Config::Simple->new($args->{'config'});
    } catch {
        $err = shift;
    };
    
    unless($args->{'config'}){
        return('unknown or missing config: '.$self->get_client_config());
    }
    if($err){
        my @errmsg;
        push(@errmsg,'something is broken in your local config: '.$args->{'config'});
        push(@errmsg,'this is usually a syntax error problem, double check '.$args->{'config'}.' and try again');
        return(join("\n",@errmsg));
    }

    $self->set_config(          $args->{'config'}->param(-block => 'cif_smrt'));
    $self->set_feeds_config(    $args->{'config'}->param(-block => 'cif_feeds'));
    
    $self->init_config_severity($args);
    
    return(undef,1);
}

sub init_config_severity {
    my $self = shift;
    my $args = shift;
    
    my $map = $args->{'config'}->param(-block => 'cif_smrt_severity');
    $map = DEFAULT_SEVERITY_MAP() unless(keys %$map);
    
    $self->set_severity_map($map);
    
}

sub init_rules {
    my $self = shift;
    my $args = shift;
    
    my $rulesfile = $args->{'rules'};
    my ($err,@errmsg);
    try {
        $args->{'rules'} = Config::Simple->new($args->{'rules'});
    } catch {
        $err = shift;
    };
    
    return('missing or unknown rules configuration: '.$rulesfile) unless($args->{'rules'});
    
    if($err){
        my @errmsg;
        push(@errmsg,'there is something broken with: '.$rulesfile);
        push(@errmsg,'this is usually a syntax problem, double check '.$rulesfile.' and try again');
        return(join("\n",@errmsg));
    }
    
    unless($args->{'feed'}){
        my @sections = keys %{$args->{'rules'}->{'_DATA'}};
        @sections = map { $_ = $_ if($_ !~ /^default/) } @sections;
        my $string = "missing feed, please set (-f) one of the following for this config:\n\n";
        $string .= join("\n",@sections);
        return($string);
    }

    $self->set_feed($args->{'feed'});
    my $defaults    = $args->{'rules'}->param(-block => 'default');
    my $rules       = $args->{'rules'}->param(-block => $self->get_feed());
    
    return ('invalid feed: '.$self->get_feed().'...') unless(keys %$rules);
   
    map { $defaults->{$_} = $rules->{$_} } keys (%$rules);
    
    $defaults->{'guid'} = 'everyone' unless($defaults->{'guid'});
    unless(is_uuid($defaults->{'guid'})){
        $defaults->{'guid'} = generate_uuid_url($defaults->{'guid'});
    }

    $self->set_rules($defaults);
    return(undef,1);
}

sub init_feeds {
    my $self = shift;
    
    my $feeds = $self->get_feeds_config->{'enabled'} || return;
    $self->set_feeds($feeds);
}

sub pull_feed { 
    my $f = shift;
    my $ret = threads->create('_pull_feed',$f)->join();
    return(undef,'') unless($ret);
    return($ret) if($ret =~ /^ERROR: /);

    # auto-decode the content if need be
    $ret = _decode($ret,$f);

    return(undef,$ret) if($f->{'cif'} && $f->{'cif'} eq 'true');

    # encode to utf8
    $ret = encode_utf8($ret);
    
    # remove any CR's
    $ret =~ s/\r//g;
    delete($f->{'feed'});
    
    return(undef,$ret);
}

# we do this sep cause it's in a thread
# this gets around memory leak issues and TLS threading issues with Crypt::SSLeay, etc
sub _pull_feed {
    my $f = shift;
    return unless($f->{'feed'});
    
    foreach my $key (keys %$f){
        foreach my $key2 (keys %$f){
            if($f->{$key} =~ /<$key2>/){
                $f->{$key} =~ s/<$key2>/$f->{$key2}/g;
            }
        }
    }
    my @pulls = __PACKAGE__->plugins();
    @pulls = sort grep(/::Pull::/,@pulls);
    foreach(@pulls){
        my ($err,$ret) = $_->pull($f);
        return('ERROR: '.$err) if($err);
        
        # we don't want to error out if there's just no content
        next unless(defined($ret));
        return($ret);
    }
    return('ERROR: could not pull feed');
}


## TODO -- turn this into plugins
sub parse {
    my $self = shift;
    my $f = $self->get_rules();
    
    if($self->get_proxy()){
        $f->{'proxy'} = $self->get_proxy();
    }
    return 'feed does not exist' unless($f->{'feed'});
    debug('pulling feed: '.$f->{'feed'}) if($::debug);
    if($self->get_client_config()){
        $f->{'client_config'} = $self->get_client_config();
    }
    my ($err,$content) = pull_feed($f);
    return($err) if($err);
    
    my $return;
    ## TODO -- this mess will be cleaned up and plugin-ized in v2
    try {
        if(my $d = $f->{'delimiter'}){
            require CIF::Smrt::ParseDelim;
            $return = CIF::Smrt::ParseDelim::parse($f,$content,$d);
        } else {
            # try to auto-detect the file
            debug('testing...');
            ## todo -- very hard to detect iodef-pb strings
            # might have to rely on base64 encoding decode first?
            ## TODO -- pull this out
            if(($f->{'driver'} && $f->{'driver'} eq 'xml') || $content =~ /^(<\?xml version=|<rss version=)/){
                if($content =~ /<rss version=/ && !$f->{'nodes'}){
                    require CIF::Smrt::ParseRss;
                    $return = CIF::Smrt::ParseRss::parse($f,$content);
                } else {
                    require CIF::Smrt::ParseXml;
                    $return = CIF::Smrt::ParseXml::parse($f,$content);
                }
            } elsif($content =~ /^\[?{/){
                ## TODO -- remove, legacy
                require CIF::Smrt::ParseJson;
                $return = CIF::Smrt::ParseJson::parse($f,$content);
            } elsif($content =~ /^#?\s?"[^"]+","[^"]+"/ && !$f->{'regex'}){
                # ParseCSV only works on strictly formated CSV files
                # o/w you should be using ParseDelim and specifying the "delimiter" field
                # in your config
                require CIF::Smrt::ParseCsv;
                $return = CIF::Smrt::ParseCsv::parse($f,$content);
            } else {
                require CIF::Smrt::ParseTxt;
                $return = CIF::Smrt::ParseTxt::parse($f,$content);
            }
        }
    } catch {
        $err = shift;
    };
    if($err){
        my @errmsg;
        if($err =~ /parser error/){
            push(@errmsg,'it appears that the format of this feed is broken and might need fixing on the authors end');
            if($::debug > 1){
                push(@errmsg,"\n\n".$err);
            } else {
                push(@errmsg,'a debug level > 1 will print the error if you wish to investigate');
            }
        } else {
            push(@errmsg,"\n\n".$err);
        }
        return(join("\n",@errmsg));
    }
    return(undef,$return);
}

sub _decode {
    my $data = shift;
    my $f = shift;

    my $ft = File::Type->new();
    my $t = $ft->mime_type($data);
    my @plugs = __PACKAGE__->plugins();
    @plugs = grep(/Decode/,@plugs);
    foreach(@plugs){
        if(my $ret = $_->decode($data,$t,$f)){
            return($ret);
        }
    }
    return $data;
}

sub _sort_timestamp {
    my $recs    = shift;
    my $rules   = shift;
    
    my $refresh = $rules->{'refresh'} || 0;

    debug('setting up sort...');
    my $x = 0;
    my $now = DateTime->from_epoch(epoch => time());
    ## TODO -- walk throught this again
    foreach my $rec (@{$recs}){
        my $dt = $rec->{'detecttime'} || $now;
        my $rt = $rec->{'reporttime'} || $now;

        $dt = normalize_timestamp($dt,$now);

        if($refresh){
            $rt = $now;
            $rec->{'timestamp_epoch'} = $now->epoch();
        } else {
            $rt = normalize_timestamp($rt,$now);
            $rec->{'timestamp_epoch'} = $dt->epoch();
        }
       
        $rec->{'detecttime'}        = $dt->ymd().'T'.$dt->hms().'Z';
        $rec->{'reporttime'}        = $rt->ymd().'T'.$rt->hms().'Z';
    }
    debug('sorting...');
    if($refresh){
        $recs = [ sort { $b->{'reporttime'} cmp $a->{'reporttime'} } @$recs ];
    } else {
        $recs = [ sort { $b->{'detecttime'} cmp $a->{'detecttime'} } @$recs ];
    }
    debug('done...');
    return($recs);
}

sub preprocess_routine {
    my $self = shift;

    debug('parsing...') if($::debug);
    my ($err,$recs) = $self->parse();
    return($err) if($err);
    
    debug('parsed records: '."\n".Dumper($recs)) if($::debug > 9);
    
    return unless($#{$recs} > -1);
    
    if($self->get_goback()){
        debug('sorting '.($#{$recs}+1).' recs...') if($::debug);
        $recs = _sort_timestamp($recs,$self->get_rules());
    }
    
    ## TODO -- move this to the threads?
    ## test with alienvault scan's feed
    debug('mapping...') if($::debug);
    
    my @array;
    foreach my $r (@$recs){
        foreach my $key (keys %$r){
            next unless($r->{$key});
            if($r->{$key} =~ /<(\S+)>/){
                my $x = $r->{$1};
                if($x){
                    $r->{$key} =~ s/<\S+>/$x/;
                }
            }
        }
        
        unless($r->{'assessment'}){
            debug('WARNING: config missing an assessment') if($::debug);
            $r->{'assessment'} = 'unknown';
        }
             
        foreach my $p (@preprocessors){
            $r = $p->process($self->get_rules(),$r);
        }
        
        # TODO -- work-around, make this more configurable
        unless($r->{'severity'}){
            $r->{'severity'} = (defined($self->get_severity_map->{$r->{'assessment'}})) ? $self->get_severity_map->{$r->{'assessment'}} : 'medium';
        }
    
        ## TODO -- if we do this, we need to degrade the count somehow...
        last if($r->{'timestamp_epoch'} < $self->get_goback());
        push(@array,$r);
    }

    debug('done mapping...') if($::debug);
    debug('records to be processed: '.($#array+1)) if($::debug);
    if($#array == -1){
        debug('your goback is too small, if you want records, increase the goback time') if($::debug);
    }

    return(undef,\@array);
}

sub process {
    my $self = shift;
    my $args = shift;
    
    
    debug('running preprocessor routine...') if($::debug);
    my ($err,$array) = $self->preprocess_routine();
    return($err) if($err);

    return (undef,'no records') unless($#{$array} > -1);
    return $self->submit($array);
}

sub submit {
    my $self = shift;
    my $data = shift;

    return $self->get_client->submit($self->get_rules->{'guid'}, $data);    
}

1;
