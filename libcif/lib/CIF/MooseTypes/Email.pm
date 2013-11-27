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

coerce 'CIF::MooseTypes::Email',
  from 'Str',
  via { 
    my $str = lc(shift); 
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $str
  };
1;



