package CIF::Encoder::Legacy;

use strict;
use warnings;
use CIF::MsgHelpers;


sub new {
  my $class = shift;
}


sub encode_submission {
  my $self = shift;
  my $apikey = shift;
  my $guid = shift;
  my $event = shift;

  my $iodefs = CIF::MsgHelpers::generate_iodef($event);
  my $msg = CIF::MsgHelpers::build_submission_msg($apikey, $guid, $iodefs);
  return($msg->encode());
}


1;
