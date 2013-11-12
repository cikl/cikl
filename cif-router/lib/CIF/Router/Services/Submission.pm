package CIF::Router::Services::Submission;
use parent 'CIF::Router::Service';

use strict;
use warnings;
use CIF::Router::Constants;
use Try::Tiny;
use CIF qw/debug/;

sub service_type { SVC_SUBMISSION }

# Should return 1 or 0
sub queue_should_autodelete {
  return 0;
}

# Should return 1 or 0
sub queue_is_durable {
  return 1;
}

sub process {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($err, $submission, $results);
  try {
    $submission = $self->encoder->decode_submission($payload);
  } catch {
    $err = shift;
  };
  if ($err) {
    die("Error while trying to decode submission: $err");
  }

  try {
    $results = $self->router->process_submission($submission);
  } catch {
    $err = shift;
  };
  if ($err) {
    die("Error while trying to process submission: $err");
  }
  return($results, "submission_response", $self->encoder->content_type(), 0);
}

1;

