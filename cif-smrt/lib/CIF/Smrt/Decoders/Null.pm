package CIF::Smrt::Decoders::Null;

use strict;
use warnings;
use CIF::Smrt::DecoderRole;
use namespace::autoclean;
use Moose;
with 'CIF::Smrt::DecoderRole';

sub decode {
    my $class = shift;
    my $dataref = shift;
    return $dataref;
}

__PACKAGE__->meta->make_immutable();

1;


