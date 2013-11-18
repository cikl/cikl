package CIF::Smrt::Parsers::ParseTxt;

use strict;
use warnings;

use Moose;
use CIF::Smrt::Parser;
extends 'CIF::Smrt::Parser';
use namespace::autoclean;

use constant NAME => 'txt';
sub name { return NAME; }

has 'regex' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'regex_values' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;
    my $re = $self->regex;
    $re = qr/$re/;
    
    my @cols = split(/\s*,\s*/, $self->regex_values);

    # This is more memory efficient.
    while(${$content_ref} =~ /([^\r\n]+)[\r\n]*/g) {
        my $line = $1;
        next if($line =~ /^(#|<|$)/);
        my @m = ($line =~ $re);
        next unless(@m);
        my $h = {};
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
