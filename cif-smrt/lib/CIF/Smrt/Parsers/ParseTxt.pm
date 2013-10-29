package CIF::Smrt::Parsers::ParseTxt;
use base 'CIF::Smrt::Parser';

use strict;
use warnings;

sub parse {
    my $self = shift;
    my $content = shift;
    my $re = $self->config->regex;
    return unless($re);
    
    my @lines = split(/[\r\n]/,$content);
    my @array;
    foreach(@lines){
        next if(/^(#|<|$)/);
        my @m = ($_ =~ /$re/);
        next unless(@m);
        my $h = $self->create_event();
        my @cols = $self->config->regex_values;
        foreach (0 ... $#cols){
            $m[$_] = '' unless($m[$_]);
            for($m[$_]){
                s/^\s+//;
                s/\s+$//;
            }
            $h->{$cols[$_]} = $m[$_];
        }
        # a work-around, we do some of this in iodef::pb::simple too
        # adding this here makes the debugging messages a little less complicated
        if($h->{'address_mask'}){
            $h->{'address'} .= '/'.$h->{'address_mask'};
        }
        push(@array,$h);
    }
    return(\@array);

}

1;
