package CIF::Archive::Plugin::Rir;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use constant DATATYPE => 'rir';
sub datatype { return DATATYPE; }

sub match_event {
  my $class = shift;
  my $event = shift;
  my $ret = $class->SUPER::match_event($event);
  if ($ret == 0) {
    return 0;
  }

  my $rir = $event->rir();
  if (!defined($rir)) {
    return 0;
  }

  unless ($rir =~ /^(afrinic|apnic|arin|lacnic|ripencc)$/i) {
    return 0;
  }

  return 1;
}

sub insert {
    my $class = shift;
    my $event = shift;
    
    unless ($class->match_event($event)) {
      return(undef);
    }

    my @ids;
 
    my $rir = lc($event->rir);

    my $id = $class->insert_hash({ 
        uuid        => $event->uuid, 
        guid        => $event->guid, 
        confidence  => $event->confidence,
        reporttime  => $event->reporttime,
      },$rir);

    push(@ids,$id);
    return(undef,\@ids);
}

1;
