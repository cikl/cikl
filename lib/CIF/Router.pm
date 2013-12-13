package CIF::Router;
use strict;
use warnings;

use Try::Tiny;
use Config::Simple;
use CIF qw/debug/;
use CIF::QueryHandler::Role;
use CIF::DataStore::Role;
use CIF::Authentication::Role;
use Mouse;

has 'datastore' => (
  is => 'ro',
  isa => 'CIF::DataStore::Role',
  required => 1
);

has 'auth' => (
  is => 'ro',
  isa => 'CIF::Authentication::Role',
  required => 1
);

has 'query_handler' => (
  is => 'ro',
  isa => 'CIF::QueryHandler::Role',
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

  return $self->query_handler->search($query);
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

  $self->datastore->submit($submission);
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
  if ($self->query_handler) {
    $self->query_handler->shutdown();
  }
}

__PACKAGE__->meta->make_immutable();

1;
