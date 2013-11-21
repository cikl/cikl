package CIF::Smrt::Handlers::ConfigBasedHandler;

use strict;
use warnings;

use Encode qw/encode_utf8/;
use CIF::Smrt::FeedParserConfig;
use CIF::Smrt::Parsers;
use CIF::Smrt::Decoders;
use CIF::Smrt::Fetchers;
use CIF::Smrt::HandlerRole;
use URI;
use CIF qw/debug/;

use Moose;
with 'CIF::Smrt::HandlerRole';

sub name {
  return 'config_based';
};

use namespace::autoclean;

has 'feedparser_config' => (
  is => 'ro',
  isa => 'CIF::Smrt::FeedParserConfig',
  required => 1
);

sub _refresh {
  my $self = shift;
  return $self->feedparser_config->{refresh};
}

sub _default_event_data {
  my $self = shift;
  return $self->feedparser_config->default_event_data;
}

sub _fetcher {
    my $self = shift;
    my $fetchers = CIF::Smrt::Fetchers->new();
    my $feedparser_config = $self->feedparser_config;
    my $feedurl = URI->new($feedparser_config->feed());
    my $fetcher_class = $fetchers->lookup($feedurl);
    if (!defined($fetcher_class)) {
      die("Could not determine fetcher");
    }

    my %args = (%$feedparser_config, proxy => $self->proxy(), feedurl => $feedurl);

    return $fetcher_class->new(%args);
}

sub _parser {
    my $self = shift;
    my $parsers = CIF::Smrt::Parsers->new();
    my $parser_name = $self->feedparser_config->parser;
    my $parser_class = $parsers->get($parser_name);
    if (!defined($parser_class)) {
      die("Could not find a parser for parser=$parser_name. Valid parsers: " . $parsers->valid_parser_names_string);
    }
    my %args = (%{$self->feedparser_config}, config => $self->feedparser_config);
    
    return $parser_class->new(%args);
}

sub decode {
    my $self = shift;
    my $dataref = shift;
    my $decoders = CIF::Smrt::Decoders->new();
    my $feedparser_config = $self->feedparser_config;
    my $feedurl = URI->new($feedparser_config->feed());
    my %args = (%$feedparser_config, feedurl => $feedurl);
    return $decoders->autodecode($dataref, \%args);
}


__PACKAGE__->meta->make_immutable;

1;

