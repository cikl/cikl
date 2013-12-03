package CIF::MooseTypes::Email;
use strict;
use warnings;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use Mail::RFC822::Address qw/valid/;

subtype 'CIF::MooseTypes::Email',
  as 'CIF::MooseTypes::LowerCaseStr',
  where { valid($_) && $_ !~ /^\s+|\s+$/ },
  message { "Invalid E-Mail address: $_"} ;
1;



