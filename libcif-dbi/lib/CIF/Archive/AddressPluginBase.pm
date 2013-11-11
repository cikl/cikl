package CIF::Archive::AddressPluginBase;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

sub init_sql {
  my $class = shift;
  my $table = $class->table();
  my $sql = qq[INSERT INTO $table (hash, uuid, guid, confidence, reporttime, address)
VALUES (?, ?, ?, ?, to_timestamp(?), ?)];
  $class->create_insert_feed($sql);
}

sub generate_feed_insert_params {
  my $class = shift;
  my $event = shift;
  my $address = lc($event->address);
  my $hash = $class->get_hashed_query_param($event);

  return (
      $hash,
      $event->uuid,
      $event->guid,
      $event->confidence,
      $event->reporttime,
      $address
    );
}

1;

