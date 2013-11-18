package CIF::Smrt::Handlers::ConfigBasedHandler;
use base 'CIF::Smrt::Handler';

use strict;
use warnings;

use Encode qw/encode_utf8/;
use CIF::Smrt::FeedParserConfig;
use CIF::Smrt::Parsers;
use CIF::Smrt::Decoders;
use CIF::Smrt::Fetchers;
use URI;

sub new {
    my $class = shift;
    my $args = shift;
    my $feedparser_config = $args->{feedparser_config};
    $args->{refresh} = $feedparser_config->{refresh};
    $args->{default_event_data} = $feedparser_config->default_event_data();

    my $self = $class->SUPER::new($args);

    $self->{feedparser_config} = $feedparser_config;
    
    if($self->proxy){
        $feedparser_config->{'proxy'} = $self->proxy;
    }

    $self->{decoders} = CIF::Smrt::Decoders->new();
    $self->{parsers} = CIF::Smrt::Parsers->new();
    $self->{fetchers} = CIF::Smrt::Fetchers->new();

    return $self;
}


sub get_fetcher {
    my $self = shift;
    my $feedparser_config = $self->{feedparser_config};
    my $feedurl = URI->new($feedparser_config->feed());
    my $fetcher_class = $self->lookup_fetcher($feedurl);
    if (!defined($fetcher_class)) {
      die("Could not determine fetcher");
    }

    return $fetcher_class->new($feedurl, $feedparser_config);
}

sub get_parser {
    my $self = shift;
    my $parser_class = $self->lookup_parser($self->{feedparser_config}->parser);
    return $parser_class->new($self->{feedparser_config});
}

sub decode {
    my $self = shift;
    my $dataref = shift;
    return $self->{decoders}->autodecode($dataref, {
        zip_filename => $self->{feedparser_config}->{zip_filename},
        feed => $self->{feedparser_config}->feed()
      });
}

sub lookup_parser {
  my $self = shift;
  my $parser_name = shift;
  my $parser_class = $self->{parsers}->get($parser_name);
  if (!defined($parser_class)) {
    die("Could not find a parser for parser=$parser_name. Valid parsers: " . $self->{parsers}->valid_parser_names_string);
  }
  return $parser_class;
}

sub lookup_fetcher {
  my $self = shift;
  my $feedurl = shift;
  return $self->{fetchers}->lookup($feedurl);
}


1;

