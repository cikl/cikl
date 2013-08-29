package CIF::MsgHelpers;

use strict;
use warnings;

use Try::Tiny;
use MIME::Base64;
use Compress::Snappy;

our @EXPORT = qw/msg_wrap_queries/;

sub msg_wrap {
    my $data = shift;
    my $type = shift;
    my $apikey = shift; # effectively optional.

    my $msg = MessageType->new({
        version => $CIF::VERSION,
        type    => $type,
        data    => $data,
        apikey  => $apikey
    });

    return $msg;
}

sub msg_wrap_queries {
    my $queries = shift;
    return msg_wrap($queries, MessageType::MsgType::QUERY());
}

sub msg_wrap_submission {
    my $data = shift;
    my $apikey = shift;

    return msg_wrap($data, MessageType::MsgType::SUBMISSION(), $apikey);
}

# Decodes and deduplicates feed response.
sub decode_feed_data {
    my $feed = shift;
    my $uuids = shift;
    my @filtered_data;

    foreach my $e (@{$feed->get_data()}){
      my $err = undef;
      $e = Compress::Snappy::decompress(decode_base64($e));
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

