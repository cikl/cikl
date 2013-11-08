package CIF::Smrt::Fetchers::File;

use strict;
use warnings;

sub fetch {
    my $class = shift;
    my $f = shift;
    
    return unless($f->{'feed'} =~ /^(\/\S+|[a-zA-Z]+\/\S+)/);
    my $file = $1;
    if($file =~ /^([a-zA-Z]+)/){
        ## TODO -- work-around, path should be passed to me by the higher level lib
        # || /opt/cif/bin is in case we run $ cif_crontool as is with no preceeding path
        my $bin_path = $FindBin::Bin || '/opt/cif/bin';
        # see if we're working out of a -dev directory
        if(-e './rules'){
            $file = $bin_path.'/../rules/'.$file;
        } else {
            $file = $bin_path.'/../'.$file;
        }
    }
    my $orig_sep = $/;
    local $/ = undef;
    open(F,$file) || return($!.': '.$file);
    my $content = <F>;
    close(F);
    $/ = $orig_sep;
    return(undef,$content);
}

1;
