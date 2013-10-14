package CIF::Models::Data;
use Data::Dumper;

require JSON;

sub new {
  my $class = shift;
  my $data = shift || {};
  my $self = bless $data, $class;
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
