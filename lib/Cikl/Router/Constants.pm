package Cikl::Router::Constants;
use strict;
use warnings;

our @ISA = qw(Exporter);

use constant {
  SVC_SUBMISSION => 1,
  SVC_QUERY => 2,
  SVC_CONTROL => 3
};

use constant {
  SVCMAP => {
    submit => SVC_SUBMISSION,
    query  => SVC_QUERY
  },
  SVCNAMES => {
    &SVC_SUBMISSION => 'submit',
    &SVC_QUERY => 'query',
    &SVC_CONTROL => 'control'
  }
};

our @EXPORT = qw(SVC_SUBMISSION SVC_QUERY SVC_CONTROL SVCMAP SVCNAMES);
