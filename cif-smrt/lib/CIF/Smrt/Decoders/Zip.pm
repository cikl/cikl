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

    my $file = $self->zip_filename;
    if(!defined($file)){
      debug("WARNING: No zip_filename provided. We'll be extracting the FIRST file that appears within the zip, whatever that may be!");
    }

    my $foundit = 0;
    my $zipfh = IO::Uncompress::Unzip->new($dataref);
    my $status;
    for ($status = 1; $status > 0; $status = $zipfh->nextStream()) {
      if (defined($file)) {
        if ($zipfh->getHeaderInfo()->{Name} eq $file) {
          # Found the file.
          $foundit = 1;
          last;
        }
      } else {
        $foundit = 1;
        last;
      }
    }

    if (!$foundit) {
      die("Failed to find file named $file");
    }
    return $zipfh;
}

__PACKAGE__->meta->make_immutable();

1;
