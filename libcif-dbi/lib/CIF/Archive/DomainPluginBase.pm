package CIF::Archive::DomainPluginBase;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use CIF qw/debug/;
use CIF::Archive::Helpers qw/is_email/;

__PACKAGE__->table('domain');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid guid hash address confidence reporttime created/);
__PACKAGE__->sequence('domain_id_seq');

use constant DATATYPE => 'domain';
sub datatype { return DATATYPE; }
sub feedtype { return DATATYPE; }

sub query { } # handled by the address module

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
  if($address =~ /^(ftp|https?):\/\//) {
    return 0;
  }
  if(is_email($address)) {
    return 0;
  }
  unless($address =~ /[a-z0-9.\-_]+\.[a-z]{2,6}$/) {
    return 0;
  }

  return 1;
}

sub insert_into_feed {
  my $class = shift;
  my $event = shift;
  my $address = lc($event->address());
  $class->index_event_for_feed($event, $address, {address => $address});
}

sub insert {
  my $class = shift;
  my $data = shift;
  my $event = $data->{event};

  my @ids;

  my $address = lc($event->address());

  my @a1 = reverse(split(/\./,$address));
  my @a2 = @a1;
  foreach (0 ... $#a1-1){
    my $a = join('.',reverse(@a2));
    pop(@a2);
    my $id = $class->insert_hash($event,$a);
    push(@ids,$id);
  }

  return(undef,\@ids);
}

1;
