package CIF::Smrt::Parsers::ParseRss;
use base 'CIF::Smrt::Parser';

use strict;
use warnings;
use XML::RSS;

sub parse {
    my $self = shift;
    my $content = shift;
    
    # fix malformed RSS
    unless($content =~ /^<\?xml version/){
        $content = '<?xml version="1.0"?>'."\n".$content;
    }
    
    my $rss = XML::RSS->new();
    my @lines = split(/[\r\n]/,$content);
    # work-around for any < > & that is in the feed as part of a url
    # http://stackoverflow.com/questions/5199463/escaping-in-perl-generated-xml/5899049#5899049
    # needs some work, the parser still pukes.
    foreach(@lines){
        s/(\S+)<(?!\!\[CDATA)(.*<\/\S+>)$/$1&#x3c;$2/g;
        s/^(<.*>.*)(?<!\]\])>(.*<\/\S+>)$/$1&#x3e;$2/g;
    }
    $content = join("\n",@lines);
    $rss->parse($content);
    my @array;
    foreach my $item (@{$rss->{items}}){
        my $h = $self->create_event();
        foreach my $key (keys %$item){
            if(my $r = $self->config->keyed_regex($key)){
                my @m = ($item->{$key} =~ /$r/);
                my @cols = $self->config->keyed_regex_values($key);
                foreach (0 ... $#cols){
                    $h->{$cols[$_]} = $m[$_];
                }
            }
        }
        push(@array,$h);
    }
    return(\@array);

}

1;
