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
  $self->{parsers} = $self->_init_parsers();

  return $self;
}

sub _init_parsers {
  my $self = shift;
  my @ret;
  foreach my $parser (__PACKAGE__->_parsers()) {
    push(@ret, $parser);
  }
  return \@ret;
}

sub lookup {
  my $self = shift;
  my $dataref = shift;
  my $feedconfig = shift;

  my $parser_class;
  ## TODO -- this mess will be cleaned up and plugin-ized in v2
  if(my $d = $feedconfig->{'delimiter'}){
    $parser_class = "CIF::Smrt::Parsers::ParseDelim";
  } else {
    # try to auto-detect the file
    debug('testing...');
    ## todo -- very hard to detect iodef-pb strings
    # might have to rely on base64 encoding decode first?
    ## TODO -- pull this out
    if(($feedconfig->{'driver'} && $feedconfig->{'driver'} eq 'xml') || $$dataref =~ /^(<\?xml version=|<rss version=)/){
      if($$dataref =~ /<rss version=/ && !$feedconfig->{'nodes'}){
        $parser_class = "CIF::Smrt::Parsers::ParseRss";
      } else {
        $parser_class = "CIF::Smrt::Parsers::ParseXml";
      }
    } elsif($$dataref =~ /^\[?{/){
      ## TODO -- remove, legacy
      $parser_class = "CIF::Smrt::Parsers::ParseJson";
    } elsif($$dataref =~ /^#?\s?"[^"]+","[^"]+"/ && !$feedconfig->{'regex'}){
      # ParseCSV only works on strictly formated CSV files
      # o/w you should be using ParseDelim and specifying the "delimiter" field
      # in your config
      $parser_class = "CIF::Smrt::Parsers::ParseCsv";
    } else {
      $parser_class = "CIF::Smrt::Parsers::ParseTxt";
    }
  }

  return $parser_class;
}

1;
