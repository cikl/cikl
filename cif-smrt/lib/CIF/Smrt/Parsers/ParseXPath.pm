package CIF::Smrt::Parsers::ParseXPath;

use strict;
use warnings;

use Moose;
use CIF::Smrt::Parser;
extends 'CIF::Smrt::Parser';
use namespace::autoclean;
use CIF::Smrt::ParserHelpers::XPathMapping;
use CIF::Smrt::ParserHelpers::XPathRegexMapping;

use XML::LibXML::Reader;

use constant NAME => 'xpath';
sub name { return NAME; }

has 'node_xpath' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'xpath_map' => (
  is => 'ro',
  isa => 'ArrayRef[CIF::Smrt::ParserHelpers::XPathMapping]',
  required => 0
);

has 'xpathregex_map' => (
  is => 'ro',
  isa => 'ArrayRef[CIF::Smrt::ParserHelpers::XPathRegexMapping]',
  required => 0
);

around BUILDARGS => sub {
  my $orig_method = shift;
  my $class = shift;
  my %args = @_;

  if (!exists($args{xpath_map})) {
    my @xpath_map;
    foreach my $key (keys %args) {
      if ($key =~ /^xpath\d+$/) {
        my ($xpath, $event_field) = @{$args{$key}};
        my $m = CIF::Smrt::ParserHelpers::XPathMapping->new(
          event_field => $event_field,
          xpath => $xpath
        );
        push(@xpath_map, $m);
      }
    }

    $args{xpath_map} = \@xpath_map;
  }
  
  if (!exists($args{xpathregex_map})) {
    my @xpathregex_map;
    foreach my $key (keys %args) {
      if ($key =~ /^xpathregex\d+$/) {
        my ($xpath, $regex, @event_fields) = @{$args{$key}};
        my $m = CIF::Smrt::ParserHelpers::XPathRegexMapping->new(
          xpath => $xpath,
          regex => qr/$regex/,
          event_fields => \@event_fields,
        );
        push(@xpathregex_map, $m);
      }
    }
    $args{xpathregex_map} = \@xpathregex_map;
  }

  return $class->$orig_method(%args);
};

sub BUILD {
  my $self = shift;

  if ( $#{$self->xpath_map} == -1 &&  $#{$self->xpathregex_map} == -1) {
    die 'at least one XPathMapping or XPathRegexMapping is required!';
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
        foreach my $x (@{$self->xpath_map}) {
          my $value = $node->findvalue($x->xpath);
          goto SKIPIT if (!defined($value));
          $h->{$x->event_field} = $value;
        }

        foreach my $x (@{$self->xpathregex_map}) {
          my $value = $node->findvalue($x->xpath);
          goto SKIPIT if (!defined($value));

          my @matches = ($value =~ $x->regex);
          goto SKIPIT if ($#matches == -1);

          my $i = 0;
          foreach my $field_name (@{$x->event_fields}) {
            $h->{$field_name} = $matches[$i];
            $i++;
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

