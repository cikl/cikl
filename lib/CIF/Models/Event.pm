package CIF::Models::Event;

use Scalar::Util qw(blessed);
use Data::Dumper;

require JSON;

sub new {
  my $class = shift;
  my $data = shift || {};
  my $self = {};
  map { $self->{$_} = $data->{$_} } keys %{$data};
  bless $self, $class;
  return $self;
}

sub to_json {
  my $self = shift;
  my $data = {};
  foreach my $key (keys %$self) {
    $data->{$key} = $self->{$key};
  }
  return JSON::encode_json($data);
}

1;
