package CIF::Smrt::Handlers::Alexa;

use strict;
use warnings;
use CIF::Smrt::Fetchers::Http;
use CIF::Smrt::Decoders::Zip;
use CIF::Smrt::Parsers::ParseDelim;
use CIF::Smrt::HandlerRole;
use CIF qw/generate_uuid_ns/;
use namespace::autoclean;
use URI;
use Moose;
with 'CIF::Smrt::HandlerRole';

# This file is initially a demonstration of a custom feed handler.


sub name {
  return 'alexa';
};

use constant ALEXA_ZIP => 'http://s3.amazonaws.com/alexa-static/top-1m.csv.zip';

sub _default_event_data {
  my $self = shift;
  return {
    guid => generate_uuid_ns('everyone'),
    assessment => 'whitelist'
  };
}

sub _fetcher {
    my $self = shift;
    return CIF::Smrt::Fetchers::Http->new(
      proxy => $self->proxy(), 
      feedurl => URI->new(ALEXA_ZIP),
      mirror => "/tmp"
    );
}

sub _parser {
    my $self = shift;
    return CIF::Smrt::Parsers::ParseDelim->new(
      delimiter => ',',
      values => 'rank,address',
      feed_limit => 10,
      config => $self->global_config(),
    );
}

sub _decoder {
    my $self = shift;
    return CIF::Smrt::Decoders::Zip->new(
      zip_filename => 'top-1m.csv',
    );
}

__PACKAGE__->meta->make_immutable;

1;
