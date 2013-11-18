package CIF::Smrt::Decoders::Zip;

use strict;
use warnings;
use CIF::Smrt::Decoder;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use Moose;
extends 'CIF::Smrt::Decoder';

has 'zip_filename' => (
  is => 'ro',
  isa => 'Str',
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
    if($self->zip_filename){
        $file = $self->zip_filename;
    } elsif ($self->feedurl =~ m/\/([a-zA-Z0-9_]+).zip$/){
        $file = $1;
    }

    unless($file) {
      die("Don't know what file to extract! Must specify 'zip_filename' in feed config.");
    }

    my $unzipped;
    unzip($dataref => \$unzipped, Name => $file) || die('unzip failed: '.$UnzipError);
    return \$unzipped;
}

1;
