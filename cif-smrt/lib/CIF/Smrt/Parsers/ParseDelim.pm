package CIF::Smrt::Parsers::ParseDelim;
use base 'CIF::Smrt::Parser';

use strict;
use warnings;

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;

    my $split = $self->config->delimiter;

    my @lines = split(/[\r\n]/,$$content_ref);
    my @cols = $self->config->values;
    
    if(my $l = $self->config->feed_limit){
        my ($start,$end);
        if(ref($l) eq 'ARRAY'){
            ($start,$end) = @{$l};
        } else {
            ($start,$end) = (0,$l-1);
        }
        @lines = @lines[$start..$end];
        
        # A feed limit may have already been applied to
        # this data.  If so, don't apply it again.
        if ($#lines > ($end - $start)){
            @lines = @lines[$start..$end];
        }
    }

    shift @lines if($self->config->skipfirst);

    foreach(@lines){
        next if(/^(#|$|<)/);
        my @m = split($split,$_);
        my $h = $self->create_event(); 
        foreach (0 ... $#cols){
            $h->{$cols[$_]} = $m[$_];
        }
        $broker->emit($h);
    }
    return(undef);
}

1;
