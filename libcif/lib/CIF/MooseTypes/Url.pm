package CIF::MooseTypes::Url;
use strict;
use warnings;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use URI;

use constant RE_URL_SCHEME => qr/^[-+.a-zA-Z0-9]+:\/\//;

# We want an absolute URL
subtype 'CIF::MooseTypes::Url',
  as 'URI',
  where { 
    my $url = shift;
    return (
      $url->isa('URI') &&
      defined($url->scheme) &&
      $url->can('host')
    );
  },
  message { "Invalid URL '$_'"} ;

coerce 'CIF::MooseTypes::Url',
  from 'Str',
  via { 
    my $str = shift; 
    if ($str !~ RE_URL_SCHEME) {
      # Default to 'http' if a scheme has not been specified. 
      $str = "http://$str";
    }
    return URI->new($str)->canonical;
  };


1;

