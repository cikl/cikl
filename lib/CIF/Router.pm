package CIF::Router;
use strict;
use warnings;

use Try::Tiny;
use Config::Simple;
use CIF qw/debug/;
use CIF::DataStore;
use CIF::Authentication::Role;
use CIF::Models::QueryResults;
use Mouse;

has 'datastore' => (
  is => 'ro',
  isa => 'CIF::DataStore',
  required => 1
);

has 'auth' => (
  is => 'ro',
  isa => 'CIF::Authentication::Role',
  required => 1
);


sub process_query {
  my $self = shift;
  my $query = shift;
  #my $msg = shift;

  my $results = [];

  my $apikey_info = $self->auth->authorized_read(
    $query->apikey, $query->group());

  if (!defined($query->group())) {
    $query->group($apikey_info->{'default_group'});
  }

  my $events = $self->datastore->search($query);

  my $query_results = CIF::Models::QueryResults->new({
      query => $query,
      events => $events,
      reporttime => time(),
      group => $query->group() || $apikey_info->{'default_group'}
    });

  return $query_results;
}

sub process_submission {
  my $self = shift;
  my $submission = shift;
  my $apikey = $submission->apikey();

  my $group = $submission->event->group();
  my $auth = $self->auth->authorized_write($submission->apikey(), 
    $group);

  if (!$auth) {
    return("apikey '$apikey' is not authorized to write for group '$group'");
  }

  #debug('inserting...') if($debug > 4);
  my ($err, $id) = $self->datastore->submit($submission);
  if ($err) { 
    debug("ERR: " . $err);
    return $err;
  }

  return undef;
}

sub shutdown {
  my $self = shift;
  if ($self->datastore) {
    $self->datastore->shutdown();
  }
  if ($self->auth) {
    $self->auth->shutdown();
  }
}

__PACKAGE__->meta->make_immutable();

1;
