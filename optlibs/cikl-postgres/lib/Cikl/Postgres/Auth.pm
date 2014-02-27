package Cikl::Postgres::Auth;
use strict;
use warnings;
use Mouse;
use Cikl::Authentication::Role ();
use Cikl::Postgres::SQLRole ();
use Cikl::Postgres::AuthSQL ();
use DBI ();
use namespace::autoclean;

with  "Cikl::Authentication::Role", "Cikl::Postgres::SQLRole";

has 'sql' => (
  is => 'ro',
  isa => 'Cikl::Postgres::AuthSQL',
  init_arg => undef,
  lazy => 1,
  builder => '_build_sql'
);

sub _build_sql {
  my $self = shift;
  return Cikl::Postgres::AuthSQL->new(dbh => $self->dbh);
}


sub authorized_write {
  my $self = shift;
  my $apikey = shift;
  my $group = shift;

  my $rec = $self->sql->key_retrieve($apikey);
  return (defined($rec) && $rec->can_write() && $rec->in_group($group));
}

sub authorized_read {
    my $self = shift;
    my $key = shift;
    my $group = shift;
    
    my $rec = $self->sql->key_retrieve($key);
    die('invaild/expired apikey') unless($rec);
    if (!defined($group)) {
      $group = $rec->default_group_name;
    }

    if (!$rec->in_group($group)) {
      die("not authorized for supplied group");
    }
    
    my $ret = {
      default_group => $rec->default_group_name()
    };

    return $ret; # all good
}

after "shutdown" => sub {
  my $self = shift;
  $self->sql->shutdown();
};

__PACKAGE__->meta->make_immutable();

1;

