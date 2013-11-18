package CIF::Smrt::Parsers::ParseJson;

use strict;
use warnings;

use Moose;
use CIF::Smrt::Parser;
extends 'CIF::Smrt::Parser';
use namespace::autoclean;

use JSON;

use constant NAME => 'json';
sub name { return NAME; }

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;

    my @feed        = @{from_json($$content_ref)};
    my @fields      = $self->config->fields;
    my @fields_map  = $self->config->fields_map;
    foreach my $a (@feed){
        my $h = {};
        foreach (0 ... $#fields_map){
            my $v = $a->{$fields[$_]};
            if (defined($v)) {
              $h->{$fields_map[$_]} = lc($v);
            }
        }
        $broker->emit($h);
    }
    return(undef);
}

__PACKAGE__->meta->make_immutable;

1;
