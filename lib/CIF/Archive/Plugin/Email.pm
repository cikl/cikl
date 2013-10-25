package CIF::Archive::Plugin::Email;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];
use CIF::Archive::Helpers qw/generate_sha1_if_needed/;

__PACKAGE__->table('email');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(Essential => qw/id uuid guid hash confidence reporttime created/);
__PACKAGE__->sequence('email_id_seq');

my @plugins = __PACKAGE__->plugins();

use constant DATATYPE => 'email';
sub datatype { return DATATYPE; }

sub is_email {
    my $e = shift;
    return unless($e);
    return if($e =~ /^(ftp|https?):\/\//);
    return unless(lc($e) =~ /^([\w+.-_]+\@[a-z0-9.-]+\.[a-z0-9.-]{2,8})$/);
    return(1);
}

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

sub insert {
    my $class = shift;
    my $data = shift;
    
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

    my $tbl = $class->table();
    my @ids;

    $class->table($matched_plugin->table());
    my $address = lc($event->address());


    my $hash = generate_sha1_if_needed($address);
    if($class->test_feed($data)){
      $class->SUPER::insert({
          uuid        => $event->uuid,
          guid        => $event->guid,
          hash        => $hash,
          confidence  => $event->confidence,
          reporttime  => $event->reporttime,
        });
    }

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
      my $id = $class->insert_hash({ 
          uuid        => $event->uuid, 
          guid        => $event->guid, 
          confidence  => $event->confidence,
          reporttime  => $event->reporttime,
        },$a);
      push(@ids,$id);
    }
    $class->table($tbl);
    return(undef,\@ids);
        
}

1;
