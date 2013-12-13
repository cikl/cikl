package CIF::Router::Services::Submission;

use strict;
use warnings;
use CIF::Router::Constants;
use CIF::Router::Service;
use Try::Tiny;
use CIF qw/debug/;
use Mouse;
with 'CIF::Router::Service';
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

sub process {
  my $self = shift;
  my $payload = shift;
  my $content_type = shift;
  my ($err, $submission, $results);
  try {
    $submission = $self->codec->decode_submission($payload);
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
  return($results, "submission_response", $self->codec->content_type(), 0);
}

__PACKAGE__->meta->make_immutable();

1;

