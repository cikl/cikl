package CIF::Smrt::Parsers::ParseXml;

use strict;
use warnings;

use Moose;
use CIF::Smrt::Parser;
extends 'CIF::Smrt::Parser';
use namespace::autoclean;

require XML::LibXML;

use constant NAME => 'xml';
sub name { return NAME; }

has 'node' => (
  is => 'ro'
);

has 'elements' => (
  is => 'ro'
);

has 'elements_map' => (
  is => 'ro'
);

has 'attributes' => (
  is => 'ro'
);

has 'attributes_map' => (
  is => 'ro'
);

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;
    
    my $parser      = XML::LibXML->new();
    my $doc         = $parser->load_xml(string => $$content_ref);
    my @nodes       = $doc->findnodes('//'.$self->config->node);
    
    return unless(@nodes);
    
    my @elements        = $self->config->elements; 
    my @elements_map    = $self->config->elements_map; 
    my @attributes_map  = $self->config->attributes_map; 
    my @attributes      = $self->config->attributes; 
    
    foreach my $node (@nodes){
        my $h = {};
        my $found = 0;
        if(@elements_map){
            foreach my $e (0 ... $#elements_map){
                my $x = $node->findvalue('./'.$elements[$e]);
                next unless($x);
                if(my $r = $self->config->regex_for($elements[$e])){
                    if($x =~ $r){
                        $h->{$elements_map[$e]} = $x;
                        $found = 1;
                    } else {
                        $found = 0;
                    }
                } else {
                    $h->{$elements_map[$e]} = $x;
                    $found = 1;
                }
            }
        } else {
            foreach my $e (0 ... $#attributes_map){       
                my $x = $node->getAttribute($attributes[$e]);
                next unless($x);
                if(my $r = $self->config->regex_for($attributes[$e])){
                    if($x =~ $r){
                        $h->{$attributes_map[$e]} = $x;
                        $found = 1;
                    } else {
                        $found = 0;
                    }
                } else {
                    $h->{$attributes_map[$e]} = $x;
                    $found = 1;
                }
            }
        }
        $broker->emit($h) if ($found);

    }
    return(undef);
}

__PACKAGE__->meta->make_immutable;

1;
