package CIF::Archive::EmailPluginBase;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use CIF::Archive::Helpers qw/is_email/;

__PACKAGE__->table('email');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(Essential => qw/id uuid guid hash confidence reporttime created/);
__PACKAGE__->sequence('email_id_seq');

use constant DATATYPE => 'email';
sub datatype { return DATATYPE; }
sub feedtype { return DATATYPE; }

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
  unless(is_email($address)) {
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
    my $class = shift;
    my $data = shift;
    my $event = $data->{event};

    my @ids;

    my $address = lc($event->address());

    # TODO MPR : I know this is attempting to 'index' the email address, but 
    # it's not clear exactly what is going on here. It seems to index both the 
    # full email "user@sub1.foobar.com" and the top two levels of the domain,
    # "foobar.com" . It seems like it should be indexing each level of the
    # domain, "sub1.foobar.com" included.
    #
    $address =~ /^([\w+.-_]+\@[a-z0-9.-]+\.[a-z0-9.-]{2,8})$/;
    $address = $1;
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
