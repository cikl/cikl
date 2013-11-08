package CIF::Smrt::Parsers;

use strict;
use warnings;
use CIF qw/debug/;

use Module::Pluggable search_path => "CIF::Smrt::Parsers", 
      require => 1, sub_name => '_parsers';


## time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/00_alexa_whitelist.cfg -f top100 -v2
#use CIF::Smrt::Parsers::ParseDelim;
#
## time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/malwaredomainlist.cfg -f malwaredomainlist -v2
#use CIF::Smrt::Parsers::ParseCsv;
#
## time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/phishtank.cfg -f urls -v2 
#use CIF::Smrt::Parsers::ParseJson;
#
## time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/zeustracker.cfg -f binaries -g 90
#use CIF::Smrt::Parsers::ParseRss;
#
## time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/misc.cfg -f sshbl.org
#use CIF::Smrt::Parsers::ParseTxt;
#
## time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/cleanmx.cfg -f malware 
#use CIF::Smrt::Parsers::ParseXml;

sub new {
  my $class = shift;

  my $self = {};

  bless $self, $class;
  $self->{parser_map} = $self->_init_parsers();

  return $self;
}

sub _init_parsers {
  my $self = shift;
  my $ret = {};
  foreach my $parser (__PACKAGE__->_parsers()) {
    my $parser_name = $parser->name();
    if (my $existing = $ret->{$parser_name}) {
      die("Cannot associate $parser with $parser_name. Already registered with $existing.");
    }
    $ret->{$parser_name} = $parser;
  }
  return $ret;
}

sub valid_parser_names {
  my $self = shift;
  return(keys(%{$self->{parser_map}}));
}

sub valid_parser_names_string {
  my $self = shift;
  return(join(", ", $self->valid_parser_names()));
}

sub get {
  my $self = shift;
  my $parser_name = shift;
  return $self->{parser_map}->{$parser_name};
}

1;
