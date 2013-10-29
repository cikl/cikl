package CIF::Smrt::Parsers::ParseCsv;
use base 'CIF::Smrt::Parser';

use strict;
use warnings;
use Text::CSV;

sub parse {
    my $self = shift;
    my $content = shift;
    
    my @lines = split(/[\r\n]/,$content);
    my @array;
    
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
    
    my $csv = Text::CSV->new({binary => 1});
    my @cols = $self->config->values;

    shift @lines if($self->config->skipfirst);
    
    foreach(@lines){
        next if(/^(#|<|$)/);
        my $row = $csv->parse($_);
        next unless($row);
        my $h = $self->create_event();
        my @m = $csv->fields();
        foreach (0 ... $#cols){
            next if($cols[$_] eq 'null');
            $h->{$cols[$_]} = $m[$_];
        }
        push(@array,$h);
    }
    return(\@array);

}

1;
