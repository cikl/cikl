package CIF::Archive::UrlPluginBase;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use CIF qw/debug/;
use CIF::Archive::Helpers qw/generate_sha1_if_needed/;

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

sub insert {
    my $class   = shift;
    my $event = shift;
    my $addr = lc($event->address());
    my $id = $class->insert_hash($event, $addr);
    return(undef,[$id]);
}

1;
