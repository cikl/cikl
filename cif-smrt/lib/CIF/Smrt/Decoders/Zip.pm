package CIF::Smrt::Decoders::Zip;

use strict;
use warnings;
use CIF::Smrt::DecoderRole;
use CIF::Smrt::AutoDecodableRole;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use Moose;
use namespace::autoclean;
use CIF qw/debug/;
with 'CIF::Smrt::DecoderRole';
with 'CIF::Smrt::AutoDecodableRole';

has 'zip_filename' => (
  is => 'ro',
  isa => 'Maybe[Str]',
  required => 0
);

use constant MIME_TYPES => (
  'application/x-zip',
  'application/zip'
);
sub mime_types { return MIME_TYPES; }

sub decode {
    my $self = shift;
    my $dataref = shift;

    my $file;
    if(!defined($self->zip_filename)){
      debug("WARNING: No zip_filename provided. We'll be extracting the FIRST file that appears within the zip, whatever that may be!");
    }

    my $unzipped;
    unzip($dataref => \$unzipped, Name => $self->zip_filename) || die('unzip failed: '.$UnzipError);
    return \$unzipped;
}

__PACKAGE__->meta->make_immutable();

1;
