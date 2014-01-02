package CIF::Client;

use strict;
use warnings;
use Mouse;
use namespace::autoclean;
use Try::Tiny;
use Config::Simple;
use CIF::Client::Transport;
use CIF::Models::Submission;
use CIF::Models::Query;
use CIF::Models::HostInfo;

use CIF qw(debug);

has 'apikey' => (
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'transport' => (
  is => 'ro',
  isa => 'CIF::Client::Transport',
  required => 1,
  predicate => 'has_transport',
  clearer => 'clear_transport'
);

sub DEMOLISH {
    my $self = shift;
    $self->shutdown();
}

sub shutdown {
    my $self = shift;
    if ($self->has_transport()) {
      $self->transport()->shutdown();
      $self->clear_transport();
    }
    return 1;
}

sub query {
    my $self = shift;
    my %args = @_;

    $args{apikey} //= $self->apikey();

    my $err;
    my $query;
    
    try {
      $query = CIF::Models::Query->new(%args);
    } catch {
      $err = $_;
    };

    if (!defined($query)) {
      die("Failed to create query object: $err");
    }

    my $query_results = $self->transport->_query($query);

    return($query_results);
}

sub submit {
    my $self = shift;
    my $event = shift;

    my $submission = CIF::Models::Submission->new(
      apikey => $self->apikey(), 
      event => $event
    );
    return $self->transport()->_submit($submission);
}    

sub ping {
    my $self = shift;

    my $hostinfo = CIF::Models::HostInfo->generate({uptime => 0, service_type => 'client'});

    return $self->transport()->_ping($hostinfo);
}    

__PACKAGE__->meta->make_immutable();
1;
