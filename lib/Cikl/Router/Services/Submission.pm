package Cikl::Router::Services::Submission;

use strict;
use warnings;
use Cikl::Router::Constants;
use Cikl::Router::ServiceRole;
use Cikl::Router::AuthenticatedRole;
use Cikl::Router::DataSubmissionRole;
use Cikl qw/debug/;
use Mouse;
with 'Cikl::Router::ServiceRole', 
     'Cikl::Router::AuthenticatedRole', 
     'Cikl::Router::DataSubmissionRole';

use namespace::autoclean;

sub service_type { Cikl::Router::Constants::SVC_SUBMISSION }

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

