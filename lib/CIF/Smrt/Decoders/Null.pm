package CIF::Smrt::Decoders::Null;

use strict;
use warnings;
use CIF::Smrt::DecoderRole;
use namespace::autoclean;
use Mouse;
with 'CIF::Smrt::DecoderRole';
with 'CIF::Smrt::AutoDecodableRole';
use constant MIME_TYPES => (
  'application/octet-stream'
);
sub mime_types { return MIME_TYPES; }

sub decode {
    my $class = shift;
    my $fh = shift;
    return $fh;
}

__PACKAGE__->meta->make_immutable();

1;


