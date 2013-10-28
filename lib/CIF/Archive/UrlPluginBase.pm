package CIF::Archive::UrlPluginBase;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use CIF qw/debug/;

use constant DATATYPE => 'url';
sub datatype { return DATATYPE; }
sub feedtype { return DATATYPE; }

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

sub insert_into_feed {
  my $class = shift;
  my $event = shift;
  my $address = lc($event->address());
  $class->index_event_for_feed($event, $address);
}

sub insert {
    my $class   = shift;
    my $data    = shift;
    
    my $event = $data->{event};

    my @ids;

    my $addr = lc($event->address());

    my $id = $class->insert_hash({ 
        uuid        => $event->uuid, 
        guid        => $event->guid, 
        confidence  => $event->confidence,
        reporttime  => $event->reporttime,
      },$addr);
    push(@ids,$id);
    return(undef,\@ids);
}

1;
