package CIF::Client::Transport;
use base 'Class::Accessor';

use strict;
use warnings;
use Scalar::Util qw(blessed);
use CIF::Encoder::JSON;
use CIF::Models::Submission;

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(qw(config global_config));

sub new {
    my $class = shift;
    my $args = shift;
 
    my $self = { };
    bless($self,$class);

    my $global_config = $args->{'config'};
    my $driver_config = $global_config->param(-block => 'client_'.$args->{driver_name});

    $self->{encoder} = CIF::Encoder::JSON->new();
    $self->{running} = 1;
    $self->set_config($driver_config);
    $self->set_global_config($global_config);
    return($self);
}

sub DESTROY {
    my $self = shift;
    $self->shutdown();
}

sub running {
    my $self = shift;
    return($self->{running});
}

sub encode_submission {
  my $self = shift;
  my $submission = shift;
  return $self->{encoder}->encode_submission($submission);
}

sub encode_query {
  my $self = shift;
  my $query = shift;
  return $self->{encoder}->encode_query($query);
}

sub decode_query_results {
  my $self = shift;
  my $content_type = shift;
  my $answer = shift;
  return $self->{encoder}->decode_query_results($answer);
}

# This gets called before shutdown.
sub shutdown {
    my $self = shift;
    if ($self->running()) {
      $self->{running} = 0;
      return(1);
    }

    return 0;
}

sub query {
    my $self = shift;
    my $queries = shift;

    die(blessed($self) . " has not implemented the query() method!");
}

sub submit {
    my $self = shift;
    my $submission = shift;

    die(blessed($self) . " has not implemented the submit_event() method!");
}

1;

