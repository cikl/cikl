package CIF::Client::Transport::Direct;
use base 'CIF::Client::Transport';

use strict;
use warnings;
use CIF::Router;
use CIF::Archive::SimpleFlusher;
use CIF::ArchiveDataStore;
use CIF qw/debug/;
use Time::HiRes qw/gettimeofday tv_interval/;

sub new {
    my $class = shift;
    my $args = shift;
    $args->{driver_name} = "direct";
    my $self = $class->SUPER::new($args);

    my $datastore = CIF::ArchiveDataStore->new_from_config($self->get_global_config);
    my $flusher = CIF::Archive::SimpleFlusher->new(
      commit_interval => 2,
      commit_size => 10000,
      commit_callback => sub { 
        my $count = shift;
        return if ($count == 0);
        my $start = [gettimeofday()];
        $datastore->flush();
        my $delta = tv_interval($start);
        debug("Commit of $count events took $delta seconds.");
      },

    );
    $self->{flusher} = $flusher;
    $self->{router} = CIF::Router->new({
      config => $self->get_global_config(),
      datastore => $datastore
    });

    return $self;
}

sub shutdown {
    my $self = shift;
    if (!$self->SUPER::shutdown()) {
      # We've already shutdown.
      return 0;
    }

    if ($self->{router}) {
      $self->{router}->shutdown();
      $self->{router} = undef;
    }
    return 1;
}

sub query {
    my $self = shift;
    my $query = shift;
    return $self->{router}->process_query($query);
}

sub ping {
    my $self = shift;
    my $hostinfo = shift;
}

sub submit {
    my $self = shift;
    my $submission = shift;
    return $self->{router}->process_submission($submission);
}

1;
