package CIF::Archive::Hash;
use base 'CIF::DBI';

use strict;
use warnings;

use CIF::Archive::Helpers qw/is_sha1/;
use CIF qw/debug/;

# work-around for cif-v1
use Regexp::Common qw/net/;

__PACKAGE__->table('hash');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid guid hash confidence reporttime created/);
__PACKAGE__->sequence('hash_id_seq');
__PACKAGE__->has_a(uuid => 'CIF::Archive');
__PACKAGE__->add_trigger(after_delete => \&trigger_after_delete);

sub trigger_after_delete {
    my $class = shift;
     
    my $archive = CIF::Archive->retrieve(uuid => $class->uuid());
    $archive->delete() if($archive);
}

sub insert {
    my $class   = shift;
    my $data    = shift;
    my $confidence;
    my @ids;

    # we're explicitly placing a hash
    $confidence = $data->{'confidence'};

    my $id = $class->sql_insert_hash->execute(
        $data->{'hash'},
        $data->{'uuid'},
        $data->{'guid'},
        $confidence,
        $data->{'reporttime'}
    );
    push(@ids,$id);
    return(undef,\@ids); 
}

sub query {
    my $class = shift;
    my $data = shift;
 
    return unless(is_sha1($data->{'query'}));

    return $class->search_lookup(
        $data->{'query'},
        $data->{'confidence'},
        $data->{'source'},
        $data->{'limit'},
    );
}

sub purge_hashes {
    my $self    = shift;
    my $args    = shift;
    
    my $ts = $args->{'timestamp'};
    
    debug('purging...');
    my $ret = $self->sql_purge_hashes->execute($ts);
    unless($ret){
        debug('error, rolling back...');
        $self->dbi_rollback();
        return;
    }
    $ret = $self->sql_purge_archive->execute($ts);
    debug('commit...');
    $self->dbi_commit();
    
    debug('done...');
    return (undef,$ret);
}

__PACKAGE__->set_sql('purge_archive'    => qq{
    DELETE FROM archive
    WHERE reporttime <= ?
});

__PACKAGE__->set_sql('purge_hashes' => qq{
    DELETE FROM __TABLE__
    WHERE reporttime <= ?
});

__PACKAGE__->set_sql('lookup' => qq{
    SELECT t1.id,t1.uuid,archive.data
    FROM (
        SELECT t2.id, t2.hash, t2.uuid, t2.guid
        FROM hash t2
        LEFT JOIN apikeys_groups on t2.guid = apikeys_groups.guid
        WHERE
            hash = ?
            AND confidence >= ?
            AND apikeys_groups.uuid = ?
        ORDER BY t2.id DESC
        LIMIT ?
    ) t1
    LEFT JOIN archive ON archive.uuid = t1.uuid
    WHERE 
        archive.uuid IS NOT NULL
});

__PACKAGE__->set_sql('insert_hash' => qq{
  INSERT INTO hash (hash, uuid, guid, confidence, reporttime)
  VALUES (?, ?, ?, ?, to_timestamp(?))
});

1;
