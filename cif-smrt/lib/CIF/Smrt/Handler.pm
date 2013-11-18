package CIF::Smrt::Handler;

use strict;
use warnings;
use Config::Simple;
use Try::Tiny;

use CIF qw/debug/;
use CIF::Smrt::Parsers;
use CIF::Smrt::Decoders;
use CIF::Smrt::Fetchers;

sub new {
  my $class = shift;
  my $args = shift;
  my $self = {};
  bless $self, $class;

  $self->{decoders} = CIF::Smrt::Decoders->new();
  $self->{parsers} = CIF::Smrt::Parsers->new();
  $self->{fetchers} = CIF::Smrt::Fetchers->new();

  # do this here, we'll do the setup within the sender_routine (thread)
  $self->{cif_config_filename} = $args->{'config'};

  $self->init_config();
  
  my $goback = $args->{'goback'} || $self->{smrt_config}->{'goback'} || 3;
  $goback = (time() - ($goback * 84600));
  $self->{goback} = $goback;

  $self->{apikey} = $args->{'apikey'} || $self->{smrt_config}->{'apikey'} || die('missing apikey');
  $self->{proxy} =  $args->{'proxy'}  || $self->{smrt_config}->{'proxy'};

  if($::debug){
    my $gb = DateTime->from_epoch(epoch => $goback);
    debug('goback: '.$gb);
  }    
    
  return $self;
}

sub init_config {
  my $self = shift;
  my $config_file = $self->{cif_config_filename};

  my $config;
  my $err;
  try {
    $config = Config::Simple->new($config_file);
  } catch {
    $err = shift;
  };

  unless($config){
    die('unknown or missing config: '. $config_file);
  }
  if($err){
    my @errmsg;
    push(@errmsg,'something is broken in your local config: '.$config_file);
    push(@errmsg,'this is usually a syntax error problem, double check '.$config_file.' and try again');
    die(join("\n",@errmsg));
  }

  $self->{smrt_config} = $config->param(-block => 'cif_smrt');
}

sub fetchers {
  my $self = shift;
  return $self->{fetchers}->fetchers();
}

sub decoders {
  my $self = shift;
  return $self->{decoders};
}

sub parsers {
  my $self = shift;
  return $self->{parsers};
}

sub proxy {
  my $self = shift;
  return $self->{proxy};
}

sub apikey {
  my $self = shift;
  return $self->{apikey};
}

sub goback {
  my $self = shift;
  return $self->{goback};
}

sub get_client {
  my $self = shift;
  my $apikey = shift;
  my ($err,$client) = CIF::Client->new({
      config  => $self->{cif_config_filename},
      apikey  => $apikey,
    });

  if ($err) {
    die($err);
  }
  return($client);
}

sub lookup_decoder {
  my $self = shift;
  my $mime_type = shift;
  return $self->{decoders}->lookup($mime_type);
}

sub lookup_parser {
  my $self = shift;
  my $parser_name = shift;
  my $parser_class = $self->{parsers}->get($parser_name);
  if (!defined($parser_class)) {
    die("Could not find a parser for parser=$parser_name. Valid parsers: " . $self->{parsers}->valid_parser_names_string);
  }
  return $parser_class;
}

sub lookup_fetcher {
  my $self = shift;
  my $feedurl = shift;
  return $self->{fetchers}->lookup($feedurl);
}



1;
