package CIF::Smrt::Decoders::Null;

use strict;
use warnings;
use CIF::Smrt::DecoderRole;
use namespace::autoclean;
use Moose;
with 'CIF::Smrt::DecoderRole';
with 'CIF::Smrt::AutoDecodableRole';
use constant MIME_TYPES => (
  'application/octet-stream'
);
sub mime_types { return MIME_TYPES; }

sub decode {
    my $class = shift;
    my $dataref = shift;
    open(my $fh, '<', $dataref);
    return $fh;
}

__PACKAGE__->meta->make_immutable();

1;


