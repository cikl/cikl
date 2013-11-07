package CIF::Smrt::Plugin::Decode::Zip;
use parent CIF::Smrt::Decoder;

use strict;
use warnings;
use IO::Uncompress::Unzip qw(unzip $UnzipError);

use constant MIME_TYPES => (
  'application/x-zip',
  'application/zip'
);
sub mime_types { return MIME_TYPES; }

sub decode {
    my $class = shift;
    my $dataref = shift;
    my $args = shift;

    my $file;
    if($args->{'zip_filename'}){
        $file = $args->{'zip_filename'};
    } elsif ($args->{'feed'} && $args->{'feed'} =~ m/\/([a-zA-Z0-9_]+).zip$/){
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
