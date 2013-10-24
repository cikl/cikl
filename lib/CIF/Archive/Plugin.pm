package CIF::Archive::Plugin;
use base 'CIF::DBI';

use warnings;
use strict;

use Digest::SHA qw/sha1_hex/;
use Iodef::Pb::Simple qw/iodef_guid iodef_confidence/;
use CIF qw/debug/;
use List::MoreUtils qw/any/;
use CIF::Archive::Hash;

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
   
    $feeds = $feeds->{'feeds'};
    return unless($feeds);
    $feeds = [$feeds] unless(ref($feeds) eq 'ARRAY');

    return unless(@$feeds);
    foreach my $f (@$feeds){
        return 1 if(lc($class) =~ /$f$/);
    }
}

sub insert_hash {
    my $class = shift;
    my $data = shift;
    my $key = shift;
    
    $key = sha1_hex($key) unless($key=~ /^[a-f0-9]{40}$/);
    
    my $id = CIF::Archive::Hash->insert({
        uuid        => $data->{'uuid'},
        guid        => $data->{'guid'},
        confidence  => $data->{'confidence'},
        hash        => $key,
        reporttime  => $data->{'reporttime'},
    });
    return ($id);
}

sub datatype {
  my $class = shift;
  die("$class->datatype has not been implemented");
}

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

sub dispatch {
    my $class = shift;
    my $data = shift;
    my $event = $data->{event};

    my $matching_plugin;
    foreach my $plugin ($class->plugins()){
      if ($plugin->match_event($event) == 1) {
        $matching_plugin = $plugin;
        last;
      }
    }
    if ($matching_plugin) {
      debug("Match $class : $matching_plugin");
    }
}

1;
