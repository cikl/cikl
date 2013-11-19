package CIF::Smrt::Parsers::ParseRss;

use strict;
use warnings;
use CIF::Smrt::ParserHelpers::RegexMapping;
use Moose;
use CIF::Smrt::Parser;
use namespace::autoclean;
use XML::RSS::LibXML;

extends 'CIF::Smrt::Parser';


use constant NAME => 'rss';
sub name { return NAME; }

around BUILDARGS => sub {
  my $orig_method = shift;
  my $class = shift;
  my %args = @_;
  use Data::Dumper;

  # Don't do anything if it rss_regex_map already exists.
  if (exists($args{rss_regex_map})) {
    return $class->$orig_method(%args);
  }

  my @regex_map;
  foreach my $key (keys %args) {
    if ($key =~ /^regex_(.*)_values$/) {
      my $name = $1;
      my $regex = $args{"regex_${name}"};
      my $values = $args{"regex_${name}_values"};
      if (!defined($regex)) {
        die("Missing matching 'regex_{$name}' for 'regex_${name}_values'!");
      }
      my @split_values = split(/\s*,\s*/, $values);
      my $m = CIF::Smrt::ParserHelpers::RegexMapping->new(
        name => $name,
        regex => qr/$regex/,
        event_fields => \@split_values
      );
      push(@regex_map, $m);
    }
  }
  $args{rss_regex_map} = \@regex_map;

  return $class->$orig_method(%args);
};

has 'rss_regex_map' => (
  traits => ['Array'],
  is => 'ro',
  isa => 'RegexMappingsRequired',
  required => 1
);

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;
    my $content = $$content_ref;

    my $regex_map = $self->rss_regex_map;

    # fix malformed RSS
    unless($content =~ /^<\?xml version/){
        $content = '<?xml version="1.0"?>'."\n".$content;
    }
    
    my $rss = XML::RSS::LibXML->new();
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
    foreach my $item (@{$rss->{items}}){
        # Conditions for bailing:
        #   - Any of the keys missing (incomplete record).
        #   - Any of the regexes not matching.
        
        my $h = {};
        foreach my $mapping (@$regex_map) {
          if (my $ret = $mapping->parse($item->{$mapping->name})) {
            # Merge the data;
            $h = {%$h, %$ret};
          } else {
            goto(SKIPIT);
          }
        }
        $broker->emit($h);
SKIPIT:
    }
    return(undef);

}

__PACKAGE__->meta->make_immutable;


1;
