package CIF::MsgHelpers;

use strict;
use warnings;

use Try::Tiny;
use CIF qw(generate_uuid_ns is_uuid debug);

our @EXPORT = qw/msg_wrap_queries/;

sub msg_wrap {
    my $data = shift;
    my $type = shift;
    my $opts = shift || {}; # effectively optional.
    my $params = {
        version => $CIF::VERSION,
        type    => $type,
        data    => $data
    };
    if (defined($opts->{apikey})) {
      $params->{'apikey'} = $opts->{apikey};
    }
    if (defined($opts->{status})) {
      $params->{'status'} = $opts->{status};
    }

    my $msg = MessageType->new($params);

    return $msg;
}

sub msg_wrap_reply {
    my $data = shift;

    return msg_wrap($data, MessageType::MsgType::REPLY(), 
      {status => MessageType::StatusType::SUCCESS()}
    );
}

sub msg_wrap_queries {
    my $queries = shift;

    foreach (@$queries) {
      $_ = $_->encode();
    }

    return msg_wrap($queries, MessageType::MsgType::QUERY());
}

sub build_submission {
    my $iodefs = shift;
    my $guid = shift;

    foreach (@$iodefs) {
      $_ = $_->encode();
    }

    my @encoded_data;

    $guid = generate_uuid_ns($guid) unless(is_uuid($guid));
    $iodefs = (ref($iodefs) eq 'ARRAY') ? $iodefs : [$iodefs];

    my $submission = MessageType::SubmissionType->new({
        guid    => $guid,
        data    => $iodefs,
    });

    return $submission;
}

sub msg_wrap_submission {
    my $data = shift;
    my $apikey = shift;

    return msg_wrap($data, MessageType::MsgType::SUBMISSION(), {apikey => $apikey});
}

sub build_submission_msg {
    my $apikey = shift;
    my $guid = shift;
    my $iodefs = shift;

    return msg_wrap_submission(build_submission($iodefs, $guid)->encode(), $apikey);
}

# Decodes and deduplicates feed response.
sub decode_feed_data {
    my $feed = shift;
    my $uuids = shift;
    my @filtered_data;

    foreach my $e (@{$feed->get_data()}){
      my $err = undef;
      try {
        $e = IODEFDocumentType->decode($e);
      } catch {
        $err = shift;
      };
      return ($err) if (defined($err));

      # This will filter out any UUIDs that have already been seen.
      my $docid = @{$e->get_Incident()}[0]->get_IncidentID->get_content();
      unless($uuids->{$docid}){
        push(@filtered_data,$e);
        $uuids->{$docid} = 1;
      }
    }

    if($#filtered_data > -1){
      $feed->set_data(\@filtered_data);
    } else {
      $feed->set_data(undef);
    }

    return (undef, $feed);
}

sub decode_msg_feeds {
    my $msg = shift;
    my $orig_feeds = $msg->get_data() || ();
    my @feeds;
    my %uuids;
    foreach my $feed (@$orig_feeds){
        my $err = undef;
        try {
            $feed = FeedType->decode($feed);
        } catch {
            $err = shift;
        };
        next if ($err);

        my ($err2, $feed2) = decode_feed_data($feed, \%uuids);

        return $err2 if (defined($err2));

        push(@feeds, $feed2);
    }

    return (undef, \@feeds);
}

sub get_msg_error {
    my $msg = shift;

    unless($msg->get_status() == MessageType::StatusType::SUCCESS()){
        return('failed: '.@{$msg->get_data()}[0]) if($msg->get_status() == MessageType::StatusType::FAILED());
        return('unauthorized') if($msg->get_status() == MessageType::StatusType::UNAUTHORIZED());
    }

    return undef;
}

sub get_uuids {
  my $iodefs = shift;
  my @uuids; 
  foreach my $iodef (@$iodefs) {
    my $i = ${$iodef->get_Incident()}[0];
    my $uuid = Iodef::Pb::Simple::iodef_uuid($i);
    push(@uuids, $uuid);
  }

  return \@uuids;
}
