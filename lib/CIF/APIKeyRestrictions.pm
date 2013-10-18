package CIF::APIKeyRestrictions;
use base 'CIF::DBI';

use CIF qw/debug/;

__PACKAGE__->table('apikeys_restrictions');
__PACKAGE__->columns(Primary => qw/uuid access/);
__PACKAGE__->columns(All => qw/uuid access created/);
__PACKAGE__->sequence('apikeys_restrictions_id_seq');
__PACKAGE__->has_a(uuid => 'CIF::APIKey');


## TODO -- this is probably backwards..
sub authorized_read_query {
    my $class = shift;
    my $apikey = shift;
    my $query = shift;
    
    my @recs = $class->search(uuid => $apikey);
    
    # if there are no restrictions, return 1
    return 1 unless($#recs > -1);
    foreach (@recs){
        # if we've given explicit access to that query (eg: domain/malware, domain/botnet, etc...)
        # return 1
        debug('access: '.$_->access());
        return 1 if($_->access() eq $query);
    }
    # fail closed
    return;
}


1;
