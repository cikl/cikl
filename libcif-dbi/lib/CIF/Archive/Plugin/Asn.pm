package CIF::Archive::Plugin::Asn;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use constant DATATYPE => 'asn';
sub datatype { return DATATYPE; }

sub match_event {
  my $class = shift;
  my $event = shift;
  my $ret = $class->SUPER::match_event($event);
  if ($ret == 0) {
    return 0;
  }

  my $asn = $event->asn();
  if (!defined($asn)) {
    return 0;
  }

  unless ($asn =~ /^\d+$/) {
    return 0;
  }

  return 1;
}

sub insert {
    my $class = shift;
    my $data = shift;
    my $event = $data->{event};

    unless ($class->match_event($event)) {
      return(undef);
    }

    my @ids;
 
    my $asn = 'as' . $event->asn();

    my $id = $class->insert_hash({ 
        uuid        => $event->uuid, 
        guid        => $event->guid,
        confidence  => $event->confidence,
        reporttime  => $event->reporttime,
      },$asn);

    push(@ids,$id);
    return(undef,\@ids);
}

1;
