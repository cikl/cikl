package CIF::Archive::Hash::Md5;
use base 'CIF::Archive::Hash';

use strict;
use warnings;

__PACKAGE__->table('hash_md5');

use constant HASH_REGEX => qr/^[a-f0-9]{32}$/;

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
