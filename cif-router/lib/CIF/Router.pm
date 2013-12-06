package CIF::Router;
use strict;
use warnings;

use Try::Tiny;
use Config::Simple;
use CIF qw/debug/;
use CIF::Models::QueryResults;

our $debug = 0;

sub new {
  my $class = shift;
  my $args = shift;

  return('missing config file') unless($args->{'config'});
  my $datastore = $args->{'datastore'} or die("Missing datastore!");

  my $self = {};
  $self->{datastore} = $datastore;
  $self->{config} = $args->{'config'}->param(-block => 'router');
  $debug = $self->{config}->{'debug'} || 0;

  bless($self,$class);
  return(undef,$self);
}

sub process_query {
  my $self = shift;
  my $query = shift;
  #my $msg = shift;

  my $results = [];

  my $apikey_info = $self->{datastore}->authorized_read($query->apikey, $query->guid());
  if (!defined($query->guid())) {
    $query->guid($apikey_info->{'default_guid'});
  }

  my ($err, $events) = $self->{datastore}->search($query);
  if (defined($err)) {
    die($err);
  }

  my $query_results = CIF::Models::QueryResults->new({
      query => $query,
      events => $events,
      reporttime => time(),
      group_map => $apikey_info->{'group_map'},
      restriction_map => $apikey_info->{'restriction_map'},
      guid => $apikey_info->{'default_guid'}
    });
  return $query_results;
}

sub process_submission {
  my $self = shift;
  my $submission = shift;
  my $apikey = $submission->apikey();

  my $guid = $submission->event->guid();
  my $auth = $self->{datastore}->authorized_write($submission->apikey(), 
    $guid);

  if (!$auth) {
    return("apikey '$apikey' is not authorized to write for guid '$guid'");
  }

  #debug('inserting...') if($debug > 4);
  my ($err, $id) = $self->{datastore}->insert_event($submission->event());
  if ($err) { 
    debug("ERR: " . $err);
    return $err;
  }

  return undef;
}

sub shutdown {
  my $self = shift;
  if ($self->{datastore}) {
    $self->{datastore}->shutdown();
    undef $self->{datastore};
  }
}

1;
