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
use CIF::Smrt::Parsers;
use Regexp::Common qw/net URI/;
use Regexp::Common::net::CIDR;
use Encode qw/encode_utf8/;
use Data::Dumper;
use File::Type;
use Module::Pluggable require => 1;
use URI::Escape;
use Try::Tiny;
use CIF::Smrt::FeedParserConfig;

use Net::SSLeay;
Net::SSLeay::SSLeay_add_ssl_algorithms();

use CIF qw/generate_uuid_url generate_uuid_random is_uuid debug normalize_timestamp/;

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(qw(
    smrt_config feeds_config feeds threads 
    entries defaults feed feedparser_config load_full goback 
    client wait_for_server name instance 
    batch_control cif_config_filename apikey
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

    # do this here, we'll do the setup within the sender_routine (thread)
    $self->set_cif_config_filename($args->{'config'});

    my ($err,$ret) = $self->init_config();
    return($err) if($err);
      
    ($err,$ret) = $self->init_rules($args->{'rules'}, $args->{'feed'});
    return($err) if($err);

    $self->set_goback(          $args->{'goback'}           || $self->get_smrt_config->{'goback'}            || 3);
    $self->set_wait_for_server( $args->{'wait_for_server'}  || $self->get_smrt_config->{'wait_for_server'}   || 0);
    $self->set_batch_control(   $args->{'batch_control'}    || $self->get_smrt_config->{'batch_control'}     || 2500); # arbitrary
    $self->set_apikey(          $args->{'apikey'}           || $self->get_smrt_config->{'apikey'}            || return('missing apikey'));
    $self->set_proxy(           $args->{'proxy'}            || $self->get_smrt_config->{'proxy'});
   
    $self->set_goback(time() - ($self->get_goback() * 84600));
    
    if($::debug){
        my $gb = DateTime->from_epoch(epoch => $self->get_goback());
        debug('goback: '.$gb);
    }    
    
    ## TODO -- this isnt' being passed to the plugins, the config is
    $self->set_name(        $args->{'name'}     || $self->get_smrt_config->{'name'}      || 'localhost');
    $self->set_instance(    $args->{'instance'} || $self->get_smrt_config->{'instance'}  || 'localhost');
    
    $self->init_feeds();

    my ($err2,$client) = CIF::Client->new({
        config  => $self->get_cif_config_filename(),
        apikey  => $self->get_apikey(),
    });
    $self->set_client($client);

    return($err,$ret) if($err);
    return(undef,1);
}

sub init_config {
    my $self = shift;
    my $config_file = $self->get_cif_config_filename();

    
    my $config;
    my $err;
    try {
        $config = Config::Simple->new($config_file);
    } catch {
        $err = shift;
    };
    
    unless($config){
        return('unknown or missing config: '. $config_file);
    }
    if($err){
        my @errmsg;
        push(@errmsg,'something is broken in your local config: '.$config_file);
        push(@errmsg,'this is usually a syntax error problem, double check '.$config_file.' and try again');
        return(join("\n",@errmsg));
    }

    $self->set_smrt_config(          $config->param(-block => 'cif_smrt'));
    $self->set_feeds_config(    $config->param(-block => 'cif_feeds'));
    
    my $map = $config->param(-block => 'cif_smrt_severity');
    $map = DEFAULT_SEVERITY_MAP() unless(keys %$map);
    
    $self->set_severity_map($map);
    
    return(undef,1);
}

sub init_rules {
    my $self = shift;
    my $rulesfile = shift;
    my $feed_name = shift;
    
    my $rules_config;
    my ($err,@errmsg);
    try {
        $rules_config = CIF::Smrt::FeedParserConfig->new($rulesfile, $feed_name);
    } catch {
        $err = shift;
    };
    
    return($err) if($err);
    $self->set_feedparser_config($rules_config);
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
    
    # MPR TODO : Fix up this key/val replacing stuff.
#    foreach my $key (keys %$f){
#        foreach my $key2 (keys %$f){
#            if($f->{$key} =~ /<$key2>/){
#                $f->{$key} =~ s/<$key2>/$f->{$key2}/g;
#            }
#        }
#    }
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
    my $f = $self->get_feedparser_config();
    
    if($self->get_proxy()){
        $f->{'proxy'} = $self->get_proxy();
    }
    return 'feed does not exist' unless($f->{'feed'});
    debug('pulling feed: '.$f->{'feed'}) if($::debug);
    if($self->get_cif_config_filename()){
        $f->{'client_config'} = $self->get_cif_config_filename();
    }
    my ($err,$content) = pull_feed($f);
    return($err) if($err);
    
    my $parser;
    ## TODO -- this mess will be cleaned up and plugin-ized in v2
    try {
        if(my $d = $f->{'delimiter'}){
            $parser = CIF::Smrt::Parsers::ParseDelim->new($f);
        } else {
            # try to auto-detect the file
            debug('testing...');
            ## todo -- very hard to detect iodef-pb strings
            # might have to rely on base64 encoding decode first?
            ## TODO -- pull this out
            if(($f->{'driver'} && $f->{'driver'} eq 'xml') || $content =~ /^(<\?xml version=|<rss version=)/){
                if($content =~ /<rss version=/ && !$f->{'nodes'}){
                    $parser = CIF::Smrt::Parsers::ParseRss->new($f);
                } else {
                    $parser = CIF::Smrt::Parsers::ParseXml->new($f);
                }
            } elsif($content =~ /^\[?{/){
                ## TODO -- remove, legacy
                $parser = CIF::Smrt::Parsers::ParseJson->new($f);
            } elsif($content =~ /^#?\s?"[^"]+","[^"]+"/ && !$f->{'regex'}){
                # ParseCSV only works on strictly formated CSV files
                # o/w you should be using ParseDelim and specifying the "delimiter" field
                # in your config
                $parser = CIF::Smrt::Parsers::ParseCsv->new($f);
            } else {
                $parser = CIF::Smrt::Parsers::ParseTxt->new($f);
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
    if (!defined($parser)) {
        return("Could not initialize parser!");
    }

    my $return = $parser->parse($content);
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
        $recs = _sort_timestamp($recs,$self->get_feedparser_config());
    }
    
    ## TODO -- move this to the threads?
    ## test with alienvault scan's feed
    debug('mapping...') if($::debug);
    
    my @array;
    foreach my $r (@$recs){
        $r = $self->handle_record($r);
    
        ## TODO -- if we do this, we need to degrade the count somehow...
        if (defined($r)) {
          push(@array,$r);
        }
    }

    debug('done mapping...') if($::debug);
    debug('records to be processed: '.($#array+1)) if($::debug);
    if($#array == -1){
        debug('your goback is too small, if you want records, increase the goback time') if($::debug);
    }

    return(undef,\@array);
}

sub handle_record {
  my $self = shift;
  my $r = shift;

  if($r->{'timestamp_epoch'} < $self->get_goback()) { 
    return(undef);
  }

  # MPR: Disabling value expansion, for now.
#  foreach my $key (keys %$r){
#    my $v = $r->{$key};
#    next unless($v);
#    if($v =~ /<(\S+)>/){
#      my $value_to_expand = $1;
#      my $x = $r->{$value_to_expand};
#      if($x){
#        $r->{$key} =~ s/<\S+>/$x/;
#      }
#    }
#  }

  unless($r->{'assessment'}){
    debug('WARNING: config missing an assessment') if($::debug);
    $r->{'assessment'} = 'unknown';
  }

  foreach my $p (@preprocessors){
    $r = $p->process($self->get_feedparser_config(),$r);
  }

  # TODO -- work-around, make this more configurable
  unless($r->{'severity'}){
    $r->{'severity'} = (defined($self->get_severity_map->{$r->{'assessment'}})) ? $self->get_severity_map->{$r->{'assessment'}} : 'medium';
  }
  return $r;
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

    my ($err, $ret);
    foreach my $event (@$data) {
      ($err, $ret) = $self->get_client->submit($self->get_feedparser_config->{'guid'}, $event);    
      if ($err) {
        return $err;
      }
    }
    return undef;
}

1;
