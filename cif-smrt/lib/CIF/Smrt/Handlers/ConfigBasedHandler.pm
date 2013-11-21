package CIF::Smrt::Handlers::ConfigBasedHandler;

use strict;
use warnings;

use Encode qw/encode_utf8/;
use CIF::Smrt::FeedParserConfig;
use CIF::Smrt::Parsers;
use CIF::Smrt::Decoders;
use CIF::Smrt::Fetchers;
use URI;
use CIF::Smrt::Handler;

use Moose;
extends 'CIF::Smrt::Handler';

use namespace::autoclean;

has 'feedparser_config' => (
  is => 'ro',
  isa => 'CIF::Smrt::FeedParserConfig',
  required => 1
);

has 'decoders' => (
  is =>'ro',
  required => 1,
  init_arg => undef,
  default => sub { CIF::Smrt::Decoders->new() }
);

has 'fetchers' => (
  is =>'ro',
  required => 1,
  init_arg => undef,
  default => sub { CIF::Smrt::Fetchers->new() }
);

has 'parsers' => (
  is =>'ro',
  required => 1,
  init_arg => undef,
  default => sub { CIF::Smrt::Parsers->new() }
);

sub BUILD {
  my $self = shift;
  # Merge our default event data into the event builder.
  $self->event_builder->merge_default_event_data(
      $self->feedparser_config->default_event_data);

  if (defined($self->feedparser_config->{refresh})) {
    $self->event_builder->refresh($self->feedparser_config->{refresh});
  }
}

sub get_fetcher {
    my $self = shift;
    my $feedparser_config = $self->feedparser_config;
    my $feedurl = URI->new($feedparser_config->feed());
    my $fetcher_class = $self->lookup_fetcher($feedurl);
    if (!defined($fetcher_class)) {
      die("Could not determine fetcher");
    }

    my %args = (%$feedparser_config, proxy => $self->proxy(), feedurl => $feedurl);

    return $fetcher_class->new(%args);
}

sub get_parser {
    my $self = shift;
    my $parser_class = $self->lookup_parser($self->feedparser_config->parser);
    my %args = (%{$self->feedparser_config}, config => $self->feedparser_config);
    
    return $parser_class->new(%args);
}

sub decode {
    my $self = shift;
    my $dataref = shift;
    my $feedparser_config = $self->feedparser_config;
    my $feedurl = URI->new($feedparser_config->feed());
    my %args = (%$feedparser_config, feedurl => $feedurl);
    return $self->decoders->autodecode($dataref, \%args);
}

sub lookup_parser {
  my $self = shift;
  my $parser_name = shift;
  my $parser_class = $self->parsers->get($parser_name);
  if (!defined($parser_class)) {
    die("Could not find a parser for parser=$parser_name. Valid parsers: " . $self->parsers->valid_parser_names_string);
  }
  return $parser_class;
}

sub lookup_fetcher {
  my $self = shift;
  my $feedurl = shift;
  return $self->fetchers->lookup($feedurl);
}

__PACKAGE__->meta->make_immutable;

1;

