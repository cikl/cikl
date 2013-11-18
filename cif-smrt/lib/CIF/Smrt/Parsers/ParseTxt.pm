package CIF::Smrt::Parsers::ParseTxt;

use strict;
use warnings;

use Moose;
use CIF::Smrt::Parser;
extends 'CIF::Smrt::Parser';
use namespace::autoclean;

use constant NAME => 'txt';
sub name { return NAME; }

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;
    my $re = $self->config->regex;
    return unless($re);
    
    my @lines = split(/[\r\n]/,$$content_ref);
    foreach(@lines){
        next if(/^(#|<|$)/);
        my @m = ($_ =~ /$re/);
        next unless(@m);
        my $h = {};
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
        $broker->emit($h);
    }
    return(undef);

}

__PACKAGE__->meta->make_immutable;

1;
