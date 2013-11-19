package CIF::Smrt::Parsers::ParseXPath;

use strict;
use warnings;

use Moose;
use CIF::Smrt::Parser;
extends 'CIF::Smrt::Parser';
use namespace::autoclean;
use CIF::Smrt::ParserHelpers::XPathMapping;

use XML::LibXML::Reader;

use constant NAME => 'xpath';
sub name { return NAME; }

has 'node_xpath' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'xml_xpath_map' => (
  is => 'ro',
  isa => 'ArrayRef[CIF::Smrt::ParserHelpers::XPathMapping]',
  required => 0
);

around BUILDARGS => sub {
  my $orig_method = shift;
  my $class = shift;
  my %args = @_;

  # Don't do anything if it xml_xpath_map already exists.
  if (exists($args{xml_xpath_map})) {
    return $class->$orig_method(%args);
  }

  my @xpath_map;
  foreach my $key (keys %args) {
    if ($key =~ /^xpath_(.*)$/) {
      my $event_field= $1;
      my $xpath = $args{$key};
      my $m = CIF::Smrt::ParserHelpers::XPathMapping->new(
        event_field => $event_field,
        xpath => $xpath
      );
      push(@xpath_map, $m);
    }
  }
  $args{xml_xpath_map} = \@xpath_map;

  return $class->$orig_method(%args);
};

sub BUILD {
  my $self = shift;

  if ( $#{$self->xml_xpath_map} == -1 ) {
    die 'xml_xpath_map: at least one XPathMapping required!';
  }
}

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;
    
    open(my $fh, '<', $content_ref) or die($!);
    my $reader      = XML::LibXML::Reader->new(IO => $fh);
    my $pattern     = XML::LibXML::Pattern->new($self->node_xpath);
    while ($reader->read()) {
        next unless ($reader->nodeType == XML_READER_TYPE_ELEMENT && 
                $reader->matchesPattern($pattern));

        my $node = $reader->copyCurrentNode(1);
    
        my $h = {};
        foreach my $x (@{$self->xml_xpath_map}) {
          if (my $value = $node->findvalue($x->xpath)) {
            $h->{$x->event_field} = $value;
          } else {
            # Didn't find it!
            print "couldn't find " . $x->event_field . "\n";
            goto SKIPIT;
          }
        }
        $broker->emit($h);
SKIPIT:
    }
    close($fh) or die($!);
    return(undef);
}

__PACKAGE__->meta->make_immutable;

1;

