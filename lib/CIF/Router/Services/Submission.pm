package CIF::Router::Services::Submission;

use strict;
use warnings;
use CIF::Router::Constants;
use CIF::Router::ServiceRole;
use CIF::Router::AuthenticatedRole;
use CIF::Router::DataSubmissionRole;
use CIF::Router::IndexerRole;
use Try::Tiny;
use CIF qw/debug/;
use Mouse;
with 'CIF::Router::ServiceRole', 
     'CIF::Router::AuthenticatedRole', 
     'CIF::Router::DataSubmissionRole',
     'CIF::Router::IndexerRole' ;

use namespace::autoclean;

sub service_type { CIF::Router::Constants::SVC_SUBMISSION }

# Should return 1 or 0
sub queue_should_autodelete {
  return 0;
}

# Should return 1 or 0
sub queue_is_durable {
  return 1;
}

sub BUILD {
  my $self = shift;
  $self->flusher->add_flush_callback(sub {
      my $submissions = shift;
      my $indexer = $self->indexer;
      my $flusher = $self->indexer_flusher;
      foreach my $submission (@$submissions) {
        $indexer->index($submission);
        $flusher->tick();
      }
    });
}

sub process {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($err, $submission);
  try {
    $submission = $self->codec->decode_submission($payload);
  } catch {
    $err = shift;
  };
  if ($err) {
    die("Error while trying to decode submission: $err");
  }

  if ($submission->has_datastore_id()) {
    # TODO : Something smarter here?
    return(0, "submission_response", $self->codec->content_type(), 0);
  }

  my $group = $submission->event->group();
  my $apikey = $submission->apikey();
  my $auth = $self->auth->authorized_write($apikey, $group);

  if (!$auth) {
    die("apikey '$apikey' is not authorized to write for group '$group'");
  }

  my $results = $self->datastore->submit($submission);

  $self->flusher->tick();

  return($results, "submission_response", $self->codec->content_type(), 0);
}

__PACKAGE__->meta->make_immutable();

1;

