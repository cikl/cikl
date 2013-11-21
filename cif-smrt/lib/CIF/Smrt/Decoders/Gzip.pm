package CIF::Smrt::Decoders::Gzip;

use strict;
use warnings;
use CIF::Smrt::DecoderRole;
use CIF::Smrt::AutoDecodableRole;
use namespace::autoclean;
use Moose;
with 'CIF::Smrt::DecoderRole';
with 'CIF::Smrt::AutoDecodableRole';

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

__PACKAGE__->meta->make_immutable();

1;

