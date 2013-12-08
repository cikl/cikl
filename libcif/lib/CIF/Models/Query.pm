package CIF::Models::Query;
use strict;
use warnings;
use Data::Dumper;
use Digest::SHA qw/sha1_hex/;
use Mouse;
use CIF::DataTypes;
use namespace::autoclean;

# this is artificially low, ipv4/ipv6 queries can grow the result set rather large (exponentially)
# most people just want a quick answer, if they override this (via the client), they'll expect the
# potentially longer query as the database grows
# later on we'll do some partitioning to clean this up a bit
use constant QUERY_DEFAULT_LIMIT => 50;

has 'apikey' => (
  is => 'rw',
  isa => 'CIF::DataTypes::LowercaseUUID',
  required => 1
);

has 'query' => (
  is => 'rw',
  isa => 'Str',
  required => 1
);

has 'guid' => (
  is => 'rw',
  isa => 'CIF::DataTypes::LowercaseUUID',
  required => 0,
);

has 'nolog' => (
  is => 'rw',
  isa => 'Bool',
  default => 0
);

has 'limit' => (
  is => 'rw',
  isa => 'Int',
  default => QUERY_DEFAULT_LIMIT
);

has 'confidence' => (
  is => 'rw',
  isa => 'Int',
  default => 0
);

has 'description' => (
  is => 'rw',
  isa => 'Str',
  lazy => 1,
  default => sub { my $self = shift; return('search ' . $self->query); }
);

sub split_query { 
  my $self = shift;
  my $q = $self->query;
  $q =~ s/\s//g;
  my @ret = split(/,/ , $q);
  return \@ret;
};

sub hashed_query { lc(sha1_hex(lc($_[0]->query))); }

sub splitup {
  my $self = shift;
  my @ret;
  foreach my $q (@{$self->split_query}) {
    push(@ret, __PACKAGE__->from_existing($self, {query => $q, description => "search $q"}));
  }
  return \@ret;
}

sub to_hash {
  my $self = shift;
  return {
    apikey => $self->apikey,
    guid => $self->guid,
    query => $self->query,
    nolog => $self->nolog,
    limit => $self->limit,
    confidence => $self->confidence,
    description => $self->description
  }
}

sub from_hash {
  my $class = shift;
  my $data = shift;
  return $class->new($data);
}

sub from_existing {
  my $class = shift;
  my $existing = shift;
  my $data = shift || {};

  return $class->new({
    apikey => $data->{apikey} // $existing->apikey,
    guid => $data->{guid} // $existing->guid,
    query => $data->{query} // $existing->query,
    nolog => $data->{nolog} // $existing->nolog,
    limit => $data->{limit} // $existing->limit,
    confidence => $data->{confidence} // $existing->confidence,
    description => $data->{description} // $existing->description
  });
}

__PACKAGE__->meta->make_immutable();

1;


