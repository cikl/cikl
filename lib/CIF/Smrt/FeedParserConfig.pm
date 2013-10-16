package CIF::Smrt::FeedParserConfig;

use strict;
use warnings;
use Data::Dumper;
use Config::Simple;
use Try::Tiny;
use CIF qw/generate_uuid_url generate_uuid_random is_uuid debug normalize_timestamp/;

sub new {
  my $class = shift;
  my $config_file = shift;
  my $feed_name = shift;

  my $config;
  my $err;
  try {
    $config = Config::Simple->new($config_file);
  } catch {
    $err = shift;
  };

  if (defined($err)) {
    die "Syntax error while parsing $config_file: $err";
  }

  my $config_data = $config->param(-block => 'default');
  my $feed_rules = $config->param(-block => $feed_name);

  if (!defined($feed_rules)) {
    die "Unknown section '$feed_name' for $config_file";
  }

  # Override any configuration with sub config.
  map { $config_data->{$_} = $feed_rules->{$_} } keys (%$feed_rules);
  
  my $guid = _get('guid', $config_data, 'everyone');
  my $feed = _get('feed', $config_data, undef);
  my $source = _get('source', $config_data, undef);
  my $feed_limit = _get('feed_limit', $config_data, undef);

  unless(is_uuid($guid)){
    $guid = generate_uuid_url($guid);
  }

  die_if_undefined($config_file, $feed_name, $feed, 'feed');
  die_if_undefined($config_file, $feed_name, $source, 'source');


  $config_data->{'guid'} = $guid;
  $config_data->{'feed'} = $feed;
  $config_data->{'source'} = $source;
  $config_data->{'feed_limit'} = $feed_limit;

  my $self = bless($config_data,$class);

  return $self;
}

sub _get {
  my $key = shift;
  my $c1 = shift;
  my $default = shift;
  return(delete($c1->{$key}) || $default);
}

sub die_if_undefined {
  my $config_file = shift;
  my $feed_name = shift;
  my $v= shift;
  my $key = shift;
  if (!defined($v)) {
    die "Missing required configuration '$key' from '$config_file' - [$feed_name]";
  }
}

sub values {
  my $self = shift;
  return split(',',$self->{values});
}

sub fields {
  my $self = shift;
  return split(',',$self->{fields});
}

sub fields_map {
  my $self = shift;
  return split(',',$self->{fields_map});
}

sub _split {
  my $self = shift;
  my $field = shift;
  if (defined($self->{$field})) {
    return split(',',$self->{$field});
  }
  return(undef);
}

sub elements {
  my $self = shift;
  return $self->_split("elements");
}

sub elements_map {
  my $self = shift;
  return $self->_split("elements_map");
}

sub attributes {
  my $self = shift;
  return $self->_split("attributes");
}

sub attributes_map {
  my $self = shift;
  return $self->_split("attributes_map");
}

sub regex_values {
  my $self = shift;
  if (ref($self->{'regex_values'}) eq 'ARRAY') {
    return $self->{'regex_values'};
  }
  return split(',',$self->{'regex_values'});
}

sub keyed_regex {
  my $self = shift;
  my $key = shift;
  return $self->{"regex_" . $key};
}

sub keyed_regex_values {
  my $self = shift;
  my $key = shift;
  my $v = $self->{"regex_" . $key . "_values"};
  return split(',', $v);
}

sub delimiter { return($_[0]->{delimiter}); }
sub feed_limit { return($_[0]->{feed_limit}); }
sub skipfirst { return($_[0]->{skipfirst}); }
sub regex { return($_[0]->{regex}); }
sub node { return($_[0]->{node}); }
sub subnode { return($_[0]->{subnode}); }

1;
