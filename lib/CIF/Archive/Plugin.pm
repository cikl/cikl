package CIF::Archive::Plugin;
use base 'CIF::DBI';

use warnings;
use strict;

use Digest::SHA qw/sha1_hex/;
use CIF qw/debug/;
use List::MoreUtils qw/any/;
use CIF::Archive::Hash;
use CIF::Archive::Helpers qw/generate_sha1_if_needed/;

sub query {}

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

sub test_feed {
    my $class = shift;
    my $feeds = shift;

    my $feedtype = $class->feedtype();
    return unless(defined($feedtype));
   
    $feeds = $feeds->{'feeds'};
    return unless($feeds);
    $feeds = [$feeds] unless(ref($feeds) eq 'ARRAY');

    return unless(@$feeds);
    foreach my $f (@$feeds){
        return 1 if($f eq $feedtype);
    }
    return undef;
}

sub insert_into_feed {
  my $class = shift;
  my $event = shift;

  # Don't do anything.
}

sub index_event_for_feed {
    my $class = shift;
    my $event = shift;
    my $field_value = shift;
    my $extra_fields = shift || {};
    my $hash = generate_sha1_if_needed($field_value);
    my $data = {
      uuid        => $event->uuid,
      guid        => $event->guid,
      hash        => $hash,
      confidence  => $event->confidence,
      reporttime  => $event->reporttime,
    };

    # Merge things together.
    %$data = (%$extra_fields, %$data);

    $class->SUPER::insert($data);
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
