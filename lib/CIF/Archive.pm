package CIF::Archive;
use base 'CIF::DBI';

require 5.008;
use strict;
use warnings;

# to make jeff teh happies!
use Try::Tiny;

use MIME::Base64;
require Compress::Snappy;
use Digest::SHA qw/sha1_hex/;
use Data::Dumper;
use POSIX ();
use CIF::Client::Query;
use CIF::APIKeyRestrictions;
use CIF::Encoder::JSON;
use CIF::Models::Query;
use CIF::Models::QueryResults;
use List::MoreUtils qw/any/;

use Devel::StackTrace;
use Module::Pluggable require => 1, except => qr/::Plugin::\S+::/, sub_name => '__plugins';
use CIF qw/generate_uuid_url generate_uuid_random is_uuid generate_uuid_ns debug/;

__PACKAGE__->table('archive');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid guid data format reporttime created/);
__PACKAGE__->columns(Essential => qw/id uuid guid data created/);
__PACKAGE__->sequence('archive_id_seq');

my $dbencoder = CIF::Encoder::JSON->new();

our $root_uuid      = generate_uuid_ns('root');
our $everyone_uuid  = generate_uuid_ns('everyone');
our $archive_plugins        = undef; # Not loaded, yet.

sub plugins {
    my $class = shift;
    if (!defined($archive_plugins)) {
      die("$class->load_plugins has not been called, yet!");
    }
    return $archive_plugins;
}

sub load_plugins {
    if (defined($archive_plugins)) {
      return 1;
    }
    
    my $class = shift;
    my $datatypes = shift;
    $archive_plugins = [];
    my @all_plugins = $class->__plugins();

    foreach my $plugin (@all_plugins) {
      if (any { $_ eq $plugin->datatype() } @$datatypes) {
        push(@$archive_plugins, $plugin);
      }
    }
    print Dumper {plugins_loaded => $archive_plugins, all_plugins => \@all_plugins};
    return 1;
}


sub insert {
    my $class       = shift;
    my $data        = shift;
    my $isUpdate    = shift;
    my $event = $data->{'event'};
        
    $data->{'uuid'}         = $event->uuid;
    $data->{'reporttime'}   = $event->reporttime;
    $data->{'guid'}         = $event->guid || $data->{'guid'};
   
    return ('id must be a uuid') unless(is_uuid($data->{'uuid'}));
    
    #$data->{'guid'}     = generate_uuid_ns('root')                  unless($data->{'guid'});
    $data->{'created'}  = DateTime->from_epoch(epoch => time())     unless($data->{'created'});
   
    #my $msg = $class->encode_event($event);
    #my $encoded = encode_base64(Compress::Snappy::compress($msg->encode()));

    my ($err,$id);
    try {
        $id = $class->SUPER::insert({
            uuid        => $data->{'uuid'},
            guid        => $data->{'guid'},
            format      => $CIF::VERSION,
            data        => $dbencoder->encode_event($event),
            created     => $data->{'created'},
            reporttime  => $data->{'reporttime'},
        });
    }
    catch {
        $err = shift;
    };
    return ($err) if($err);
    
    #$data->{'data'} = $msg;
    
    my $ret;
    ($err,$ret) = $class->insert_index($event, $data);
    return($err) if($err);
    return(undef,$data->{'uuid'});
}

sub insert_index {
    my $class   = shift;
    my $event = shift;
    my $args    = shift;
    my @plugins = @{$class->plugins};

    $args->{data} = Iodef::Pb::Simple->new($event);

    my $err;
    foreach my $p (@plugins){
        my ($pid,$err);
        try {
            $p->dispatch($args);
            ($err,$pid) = $p->insert($args);
        } catch {
            $err = shift;
        };
        if($err){
            warn $err;
            $class->dbi_rollback() unless($class->db_Main->{'AutoCommit'});
            return $err;
        }
    }
    return(undef,1);
}

sub normalize_query {
    my $class = shift;
    my $query = shift;
    my $splitup = $query->splitup();
    my @ret;

    foreach my $q (@$splitup) {
      my @new_queries; 
      foreach my $plugin (CIF::Client::Query->plugins()){
        my ($err,$r) = $plugin->process($q->to_hash);
        return($err) if($err);
        next unless($r);
        $r = [$r] unless ref($r) eq "ARRAY";

        foreach my $x (@$r) {
          push(@new_queries, CIF::Models::Query->from_existing($q, $x));
        }
        last;
      }
      if ($#new_queries > -1) {
        @ret = (@ret, @new_queries);
      } else {
        push(@ret, $q);
      }

    }
    return undef, \@ret;
}

sub search {
    my $class = shift;
    my $query = shift;

    my ($err, $normalized_queries) = $class->normalize_query($query);

    my @res;
    foreach my $m (@$normalized_queries){
        my $hashed_query = $m->hashed_query();
        my ($err2,$s) = CIF::Archive->search2($m);
        if($err){
          return('query failed, contact system administrator');
        }
        next unless($s);
        @res = (@res, @$s);
    }

    return(undef, \@res);
}

sub search2 {
    my $class = shift;
    my $query = shift;
 
    my $ret;
    if(is_uuid($query->query())) {
        $ret = $class->search_lookup(
            $query->query(),
            $query->apikey(),
        );
    } else {
        # log the query first
#        unless($data->{'nolog'}){
#            debug('logging search');
#            my ($err,$ret) = $class->log_search($data);
#            return($err) if($err);
#        }
#
        
        my $hashed_query = $query->hashed_query();
        my $err;
        try {
          $ret = CIF::Archive::Hash->query({
              query           => $hashed_query,

              description     => $query->description(),
              limit           => $query->limit(),
              confidence      => $query->confidence(),
              guid            => $query->guid(),

              nolog           => $query->nolog(),
              source          => $query->apikey(),
              apikey          => $query->apikey()
            });
        } catch {
          $err = shift;
        };
        if($err){
          warn $err;
          return($err);
        }
    }

    return unless($ret);
    my @recs = (ref($ret) ne 'CIF::Archive') ? reverse($ret->slice(0,$ret->count())) : ($ret);
    my @rr;
    foreach (@recs){
        # protect against orphans
        next unless($_->{'data'});
        my $e = $dbencoder->decode_event($_->{'data'});

        push(@rr,$e);
    }

    return(undef,\@rr);
}

sub hash_querystring {
    my $class = shift;
    my $querystring = shift;
    if ($querystring =~ /^([a-f0-9]{40}|[a-f0-9]{32})$/i) {
      return lc($querystring);
    }
    return lc(sha1_hex(lc($querystring))); 
}

# TODO: MPR, I've disabled this, for now. I don't feel like dealing with it.
sub log_search {
    my $class = shift;
    my $data = shift;
    
    my $q               = lc($data->{'query'});
    my $source          = $data->{'source'}         || 'unknown';
    my $confidence      = $data->{'confidence'}     || 50;
    my $restriction     = $data->{'restriction'}    || 'private';
    my $guid            = $data->{'guid'}           || $data->{'guid_default'} || $root_uuid;
    my $desc            = $data->{'description'}    || 'search';
    
    my $dt          = DateTime->from_epoch(epoch => time());
    $dt = $dt->ymd().'T'.$dt->hms().'Z';
    
    $source = generate_uuid_ns($source);
    
    my $id;
   
    my ($q_type,$q_thing);
    for(lc($desc)){
        # reg hashes
        if(/^search ([a-f0-9]{40}|[a-f0-9]{32})$/){
            $q_type = 'hash';
            $q_thing = $1;
            last;
        } 
        # asn
        if(/^search as(\d+)$/){
            $q_type = 'hash';
            $q_thing = sha1_hex($1); 
            last;
        } 
        # cc
        if(/^search ([a-z]{2})$/){
            $q_type = 'hash';
            $q_thing = sha1_hex($1);
            last;
        }
        m/^search (\S+)$/;
        $q_type = 'address',
        $q_thing = $1;
    }
   
    # thread friendly to load here
    ## TODO this could go in the client...?
    require Iodef::Pb::Simple;
    my $uuid = generate_uuid_random();
    
    my $doc = Iodef::Pb::Simple->new({
        description => $desc,
        assessment  => AssessmentType->new({
            Impact  => [
                ImpactType->new({
                    lang    => 'EN',
                    content => MLStringType->new({
                        content => 'search',
                        lang    => 'EN',
                    }),
                }),
            ],
            
            ## TODO -- change this to low|med|high
            Confidence  => ConfidenceType->new({
                content => $confidence,
                rating  => ConfidenceType::ConfidenceRating::Confidence_rating_numeric(),
            }),
        }),
        $q_type             => $q_thing,
        IncidentID          => IncidentIDType->new({
            content => $uuid,
            name    => $source,
        }),
        detecttime  => $dt,
        reporttime  => $dt,
        restriction => $restriction,
        guid        => $guid,
        restriction => RestrictionType::restriction_type_private(),
    });
   
    my $err;
    ($err,$id) = $class->insert({
        uuid        => $uuid,
        guid        => $guid,
        data        => $doc,
        created     => $dt,
        feeds       => $data->{'feeds'},
        datatypes   => $data->{'datatypes'},
    });
    return($err) if($err);
    $class->dbi_commit() unless($class->db_Main->{'AutoCommit'});
    return(undef,$id);
}

sub load_page_info {
    my $self = shift;
    my $args = shift;
    
    my $sql = $args->{'sql'};
    my $count = 0;
    if($sql){
        $self->set_sql(count_all => "SELECT COUNT(*) FROM __TABLE__ WHERE ".$sql);
    } else {
        $self->set_sql(count_all => "SELECT COUNT(*) FROM __TABLE__");
    }
    $count = $self->sql_count_all->select_val();
    $self->{'total'} = $count;
}

sub has_next {
    my $self = shift;
    return 1 if($self->{'total'} > $self->{'offset'} + $self->{'limit'});
    return 0;
}

sub has_prev {
    my $self = shift;
    return $self->{'offset'} ? 1 : 0;
}

sub next_offset {
    my $self = shift;
    return ($self->{'offset'} + $self->{'limit'});
}

sub prev_offset {
    my $self = shift;
    return ($self->{'offset'} - $self->{'limit'});
}

sub page_count {
    my $self = shift;
    return POSIX::ceil($self->{'total'} / $self->{'limit'});
}

sub current_page {
    my $self = shift;
    return int($self->{'offset'} / $self->{'limit'}) + 1;
}

__PACKAGE__->set_sql('lookup' => qq{
    SELECT t1.id,t1.uuid,t1.data
    FROM __TABLE__ t1
    LEFT JOIN apikeys_groups ON t1.guid = apikeys_groups.guid
    WHERE
        t1.uuid = ?
        AND apikeys_groups.uuid = ?
});

1;
