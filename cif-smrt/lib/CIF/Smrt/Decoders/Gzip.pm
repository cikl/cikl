package CIF::Smrt::Decoders::Gzip;

use strict;
use warnings;
use CIF::Smrt::Decoder;
use Moose;
extends 'CIF::Smrt::Decoder';

use IO::Uncompress::Gunzip qw/gunzip $GunzipError/;

use constant MIME_TYPES => (
  'application/x-gzip'
);
sub mime_types { return MIME_TYPES; }

sub decode {
    my $class = shift;
    my $dataref = shift;
    my $uncompressed;
    gunzip($dataref => \$uncompressed) or die($GunzipError);
    return \$uncompressed;
}

1;

