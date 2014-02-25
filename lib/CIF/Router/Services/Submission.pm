package CIF::Router::Services::Submission;

use strict;
use warnings;
use CIF::Router::Constants;
use CIF::Router::ServiceRole;
use CIF::Router::AuthenticatedRole;
use CIF::Router::DataSubmissionRole;
use CIF qw/debug/;
use Mouse;
with 'CIF::Router::ServiceRole', 
     'CIF::Router::AuthenticatedRole', 
     'CIF::Router::DataSubmissionRole';

use namespace::autoclean;

sub service_type { CIF::Router::Constants::SVC_SUBMISSION }

sub decode_payload {
  return $_[0]->codec->decode_submission($_[1]);
}

sub do_work {
  my $self = shift;
  my $submission = shift;

  if ($submission->has_datastore_id()) {
    # TODO : Something smarter here?
    return 0;
  }

  my $group = $submission->event->group();
  my $apikey = $submission->apikey();
  my $auth = $self->auth->authorized_write($apikey, $group);

  if (!$auth) {
    die("apikey '$apikey' is not authorized to write for group '$group'");
  }

  return $self->datastore->submit($submission);
}

sub encode_response {
  my $self = shift;
  my $results = shift;
  return $results;
}

use constant RESPONSE_TYPE => "submission_response";
sub response_type {
  return RESPONSE_TYPE;
}

__PACKAGE__->meta->make_immutable();

1;

