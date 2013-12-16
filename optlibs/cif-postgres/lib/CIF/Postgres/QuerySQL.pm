package CIF::Postgres::QuerySQL;
use strict;
use warnings;
use Mouse;
use CIF qw/debug/;
use namespace::autoclean;
require SQL::Abstract::More;

use constant SQL_GET_DATA_BY_IDS => q{
SELECT data FROM datastore WHERE id = ANY(?);
};

has 'dbh' => (
  is => 'ro',
  isa => 'DBI::db',
  required => 1
);

has 'get_data_by_ids_sth' => (
  is => 'ro',
  #isa => ,
  init_arg => undef,
  lazy => 1,
  default => sub { $_[0]->dbh->prepare(SQL_GET_DATA_BY_IDS) }
);

sub shutdown {
  my $self = shift;
  $self->dbh->disconnect();
}

sub _add_range {
  my $arrayref = shift;
  my $fieldname = shift;
  my $range = shift;
  
  if (defined($range->min())) {
    push(@$arrayref, {$fieldname => {">=" => $range->min()}});
  }
  if (defined($range->max())) {
    push(@$arrayref, {$fieldname => {">=" => $range->max()}});
  }
}

sub _sql_array_contains {
  my ($self, $field, $op, $arg) = @_;
  my $label         = $self->_quote($field);
  my $placeholder = $self->_convert('?');
  my $sql           = "$label <@ $placeholder";
  my @bind = $self->_bindtype($field, [$arg]);
  return ($sql, @bind);
}

sub _sql_overlaps_cidr {
  my $self = shift;
  my $field = shift;
  my $op = shift;
  my $cidr = shift;

  my $label = $self->_quote($field);
  my $placeholder = $self->_convert('?');
  my $sql = "${placeholder}::cidr >>= $label" . 
    " OR ${placeholder}::cidr <<= $label";
  my @bind = $self->_bindtype($field, $cidr, $cidr);
  return ($sql, @bind);
}

use constant SQL_ABSTRACT_SPECIAL_OPS => [
  { regex => qr/^array_contains$/, handler => \&_sql_array_contains },
  { regex => qr/^overlaps_cidr$/, handler => \&_sql_overlaps_cidr }
];

sub search {
  my $self = shift;
  my $query = shift;

  my $sql = SQL::Abstract::More->new(
    special_ops => SQL_ABSTRACT_SPECIAL_OPS
  );

  my @and;
  if ($query->group) {
    push(@and, { group_name => lc($query->group)});
  }

  my @address_criteria;

  if ($query->confidence) {
    _add_range(\@and, "confidence", $query->confidence);
  }
  if ($query->reporttime) {
    _add_range(\@and, "reporttime", $query->reporttime);
  }
  if ($query->detecttime) {
    _add_range(\@and, "created", $query->detecttime);
  }

  my @asns;
  my @emails;
  my @fqdns;
  my @urls;

  foreach my $op (@{$query->address_criteria}) {
    my $operator = $op->operator;
    if ($operator eq 'asn') {
      push(@asns, $op->value());
    } elsif ($operator eq 'email') {
      push(@emails, $op->value());
    } elsif ($operator eq 'fqdn') {
      push(@fqdns, $op->value());
    } elsif ($operator eq 'url') {
      push(@urls, $op->value());
    } elsif ($operator eq 'ip') {
      push(@address_criteria, {cidr => {-overlaps_cidr => $op->value()}});
    } else {
      die("unknown operator: " . $operator);
    }
  }

  if (@asns > 1) {
    push(@address_criteria, {asn => {-in => \@asns}});
  } elsif (@asns == 1) {
    push(@address_criteria, {asn => $asns[0]});
  }

  if (@emails > 1) {
    push(@address_criteria, {email => {-in => \@emails}});
  } elsif (@emails == 1) {
    push(@address_criteria, {email => $emails[0]});
  }

  if (@fqdns > 1) {
    push(@address_criteria, {fqdn => {-in => \@fqdns}});
  } elsif (@fqdns == 1) {
    push(@address_criteria, {fqdn => $fqdns[0]});
  }

  if (@urls > 1) {
    push(@address_criteria, {url => {-in => \@urls}});
  } elsif (@urls == 1) {
    push(@address_criteria, {url => $urls[0]});
  }

  if (scalar(@address_criteria)) {
    push(@and, {-or => \@address_criteria});
  }

  my ($stmt, @bind) = $sql->select(
    -columns => ['id'],
    -from => 'indexing',
    -where => {-and => \@and},

    # TODO add limit handling. Don't want to pull the whole DB.
    -limit => $query->limit, 
    -order_by => [ '-reporttime' ],
  );

  debug("Generated query SQL: $stmt");

  my $sth = $self->dbh->prepare_cached($stmt) or die ($self->dbh->errstr);

  $sth->execute(@bind) or die($self->dbh->errstr);

  my $ids = $sth->fetchall_arrayref();
  $ids = [ map { $_->[0] } @$ids ];
  my $sth2 = $self->get_data_by_ids_sth();

  #$sth2->execute($ids) or die($self->dbh->errstr);
  $sth2->execute($ids) or die($self->dbh->errstr);
  my $event_json = $sth2->fetchall_arrayref();

  # It's the first column of each row, so we map it down.
  $event_json =  [ map {$_->[0]} @$event_json ];
  return $event_json;

}


__PACKAGE__->meta->make_immutable();

1;

