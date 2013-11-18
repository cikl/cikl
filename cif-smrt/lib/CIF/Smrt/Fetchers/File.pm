package CIF::Smrt::Fetchers::File;
use parent CIF::Smrt::Fetcher;

use strict;
use warnings;
use URI::file;

use constant SCHEMES => (
      'file', 
      '__undef__'# this tells us that it's a relative path.
    ); 

sub schemes { 
  return SCHEMES;
}

sub fetch {
    my $self = shift;
    my $feedurl = $self->feedurl();

    if (!defined($feedurl->scheme())) {
      # it's going to be a relative URL.
      $feedurl = URI::file->new_abs($feedurl->as_string());
    }

    unless ($feedurl->scheme() eq 'file') {
      die("Unsupported URI scheme: " . $feedurl->scheme);
    }
    
    my $orig_sep = $/;
    local $/ = undef;
    open(F,$feedurl->path) || die($!.': '.$feedurl->path);
    my $content = <F>;
    close(F);
    $/ = $orig_sep;
    return(\$content);
}

1;
