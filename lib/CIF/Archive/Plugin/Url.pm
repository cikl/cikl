package CIF::Archive::Plugin::Url;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];
use CIF qw/debug/;
use CIF::Archive::Helpers qw/generate_sha1_if_needed/;

my @plugins = __PACKAGE__->plugins();

use constant DATATYPE => 'url';
sub datatype { return DATATYPE; }

__PACKAGE__->table('url');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid guid hash confidence reporttime created/);
__PACKAGE__->sequence('url_id_seq');

sub query { } # handled by hash lookup

sub match_event {
  my $class = shift;
  my $event = shift;
  my $ret = $class->SUPER::match_event($event);
  if ($ret == 0) {
    return 0;
  }

  my $address = $event->address();
  if (!defined($address)) {
    return 0;
  }
  $address = lc($address);
  if ($address !~ /^(ftp|https?):\/\//) {
    return 0;
  }

  return 1;
}

sub insert {
    my $class   = shift;
    my $data    = shift;
    
    my $event = $data->{event};

    my $matched_plugin;
    foreach my $plugin (@plugins){
      if($plugin->match_event($event)){
        $matched_plugin = $plugin;
        last;
      }
    }
    if (!defined($matched_plugin)) {
      return;
    }
    $class->table($matched_plugin->table());
    
    my $tbl = $class->table();
    my @ids;

    my $addr = lc($event->address());
    my $hash = generate_sha1_if_needed($addr);
    if($class->test_feed($data)){
      $class->SUPER::insert({
          guid        => $event->guid,,
          uuid        => $event->uuid,
          hash        => $hash,
          confidence  => $event->confidence,
          reporttime  => $event->reporttime,
        });
    }

    my $id = $class->insert_hash({ 
        uuid        => $event->uuid, 
        guid        => $event->guid, 
        confidence  => $event->confidence,
        reporttime  => $event->reporttime,
      },$addr);
    push(@ids,$id);
    $class->table($tbl);
    return(undef,\@ids);
}

1;
