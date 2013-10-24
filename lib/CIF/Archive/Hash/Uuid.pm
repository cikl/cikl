package CIF::Archive::Hash::Uuid;
use base 'CIF::Archive::Hash';

use strict;
use warnings;

__PACKAGE__->table('hash_uuid');

use constant HASH_REGEX => qr/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

sub hash_regex {
  return HASH_REGEX;
}

sub prepare {
    my $class = shift;
    my $data = shift;
    return unless(lc($data) =~ HASH_REGEX);
    return(1);
}

sub query {
    my $class = shift;
    my $data = shift;
    
    return unless($class->prepare($data->{'query'}));
    return $class->search_lookup(
        $data->{'query'},
        $data->{'confidence'},
        $data->{'limit'},
    );
}

1;
