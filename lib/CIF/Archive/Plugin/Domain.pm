package CIF::Archive::Plugin::Domain;
use base 'CIF::Archive::Plugin';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];
use Digest::SHA qw/sha1_hex/;
use CIF qw/debug/;
use CIF::Archive::Helpers qw/generate_sha1_if_needed/;

__PACKAGE__->table('domain');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid guid hash address confidence reporttime created/);
__PACKAGE__->sequence('domain_id_seq');

my @plugins = __PACKAGE__->plugins();

use constant DATATYPE => 'domain';
sub datatype { return DATATYPE; }

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
  if(CIF::Archive::Plugin::Email::is_email($address)) {
    return 0;
  }
  unless($address =~ /[a-z0-9.\-_]+\.[a-z]{2,6}$/) {
    return 0;
  }

  return 1;
}

sub insert {
  my $class = shift;
  my $data = shift;
  my $event = $data->{event};

  my $tbl = $class->table();

  foreach my $plugin (@plugins){
    if($plugin->match_event($event)){
      $class->table($class->sub_table($plugin));
      last;
    }
  }

  my @ids;

  my $address = lc($event->address());

  return if($address =~ /^(ftp|https?):\/\//);
  # this way we can change the regex as we go if needed
  return if(CIF::Archive::Plugin::Email::is_email($address));
  return unless($address =~ /[a-z0-9.\-_]+\.[a-z]{2,6}$/);
  if($class->test_feed($data)){
    $class->SUPER::insert({
        uuid        => $event->uuid,
        guid        => $event->guid,
        hash        => sha1_hex($address),
        address     => $address,
        confidence  => $event->confidence,
        reporttime  => $event->reporttime,
      });
  }

  my @a1 = reverse(split(/\./,$address));
  my @a2 = @a1;
  foreach (0 ... $#a1-1){
    my $a = join('.',reverse(@a2));
    pop(@a2);
    #my $hash = generate_sha1_if_needed($a);
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
