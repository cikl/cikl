package CIF::Archive::Plugin;
use base 'CIF::DBI';

use warnings;
use strict;

use Digest::SHA qw/sha1_hex/;
use CIF qw/debug/;
use List::MoreUtils qw/any/;
use CIF::Archive::Hash;
use CIF::Archive::Helpers qw/generate_sha1_if_needed/;

our %dispatch_table;

sub query {}

sub init_sql {
  my $class = shift;
  my $table = $class->table();
  my $sql = qq[INSERT INTO $table (hash, uuid, guid, confidence, reporttime)
VALUES (?, ?, ?, ?, to_timestamp(?))];
  $class->create_insert_feed($sql);
}

sub create_insert_feed {
  my $class = shift;
  my $sql = shift;
  my $table = $class->table;
  my $name = "insert_feed_$table";
  $class->set_sql($name => $sql);

  my $sql_name = "sql_$name";
  $dispatch_table{$class} = $class->$sql_name;
}

sub get_hashed_query_param {
  my $class = shift;
  my $event = shift;
  return(generate_sha1_if_needed(lc($event->address)));
}

sub get_feed_insert_sqlh {
  my $class = shift;
  return $dispatch_table{$class};
}

# sub tables are auto-defined by the plugin name
# eg: Domain::Phishing translates to:
# domain_phishing
sub sub_table {
    my $class = shift;
    my $plug = shift;
    
    $plug =~ m/Plugin::(\S+)::(\S+)$/;
    my ($type,$subtype) = (lc($1),lc($2));
    return $type.'_'.$subtype;
}

sub generate_feed_insert_params {
  my $class = shift;
  my $event = shift;
  my $hash = $class->get_hashed_query_param($event);

  return (
      $hash,
      $event->uuid,
      $event->guid,
      $event->confidence,
      $event->reporttime,
    );
}

sub insert_into_feed {
  my $class = shift;
  my $event = shift;
  my $method = $class->get_feed_insert_sqlh();

  $method->execute(
    $class->generate_feed_insert_params($event)
  );
}

sub insert_hash {
    my $class = shift;
    my $event = shift;
    my $key = shift;
    
    $key = sha1_hex($key) unless($key=~ /^[a-f0-9]{40}$/);
    
    my $id = CIF::Archive::Hash->insert({
        uuid        => $event->uuid,
        guid        => $event->guid,
        confidence  => $event->confidence,
        hash        => $key,
        reporttime  => $event->reporttime,
    });
    return ($id);
}

sub datatype {
  my $class = shift;
  die("$class->datatype has not been implemented");
}

sub feedtype { return undef; }

sub assessment_regex {
  return undef;
}

sub match_event {
  my $class = shift;
  my $event = shift;
  if (my $re = $class->assessment_regex()) {
    unless (defined($event->assessment())) {
      # No assessment on the event? no match.
      return 0;
    }
    # If the event's assessment doesn't match the regex, no match.
    if ($event->assessment() !~ $re) {
      return 0;
    }
  }

  # Default to matching.
  return 1;
}

1;
