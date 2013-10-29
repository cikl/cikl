package CIF::Models::Query;
use strict;
use warnings;
use Data::Dumper;
use Digest::SHA qw/sha1_hex/;

use constant MANDATORY_FIELDS => qw/apikey query/;

# this is artificially low, ipv4/ipv6 queries can grow the result set rather large (exponentially)
# most people just want a quick answer, if they override this (via the client), they'll expect the
# potentially longer query as the database grows
# later on we'll do some partitioning to clean this up a bit
use constant QUERY_DEFAULT_LIMIT => 50;

sub new {
  my $class = shift;
  my $args = shift;
  my $self = {};

  for(MANDATORY_FIELDS) {
    die "Missing $_ parameter\n" unless exists($args->{$_});
  }

  $self->{apikey} = $args->{apikey};
  $self->{guid} = $args->{guid};
  $self->{query} = $args->{query};
  $self->{nolog} = $args->{nolog} || 0;
  $self->{limit} = $args->{limit} || QUERY_DEFAULT_LIMIT;
  $self->{confidence} = $args->{confidence} || 0;
  $self->{description} = $args->{'description'} || 'search ' . $self->{query};

  bless $self, $class;
  return $self;
}

sub apikey { $_[0]->{apikey} };
sub guid { $_[0]->{guid} };
sub set_guid { $_[0]->{guid} = $_[1]; };
sub query { $_[0]->{query} };
sub split_query { 
  my $self = shift;
  my $q = $self->query;
  $q =~ s/\s//g;
  my @ret = split(/,/ , $q);
  return \@ret;
};

sub nolog { $_[0]->{nolog} };
sub limit { $_[0]->{limit} };

sub confidence { $_[0]->{confidence} };
sub description { $_[0]->{description} };

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

1;


