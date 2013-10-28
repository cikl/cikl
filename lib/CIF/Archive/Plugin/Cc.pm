package CIF::Archive::Plugin::Cc;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

my @plugins = __PACKAGE__->plugins();

use constant DATATYPE => 'cc';
sub datatype { return DATATYPE; }

sub match_event {
  my $class = shift;
  my $event = shift;
  my $ret = $class->SUPER::match_event($event);
  if ($ret == 0) {
    return 0;
  }

  my $cc = $event->cc();
  if (!defined($cc)) {
    return 0;
  }

  unless ($cc =~ /^[A-Za-z]{2}$/) {
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
 
    my $cc = lc($event->cc());

    my $id = $class->insert_hash({ 
        uuid        => $event->uuid, 
        guid        => $event->guid,
        confidence  => $event->confidence,
        reporttime  => $event->reporttime,
      },$cc);

    push(@ids,$id);
    return(undef,\@ids);
}

1;
