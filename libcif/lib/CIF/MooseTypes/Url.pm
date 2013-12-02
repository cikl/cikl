package CIF::MooseTypes::Url;
use strict;
use warnings;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use URI;

use constant RE_URL_SCHEME => qr/^[-+.a-zA-Z0-9]+:\/\//;
our @ALLOWED_SCHEMES = qw(
  http
  https
  ftp
);
our $RESTR_ALLOWED_SCHEMES = join('|', @ALLOWED_SCHEMES);
our $RE_ALLOWED_SCHEMES = qr/^($RESTR_ALLOWED_SCHEMES)$/;

# We want an absolute URL
subtype 'CIF::MooseTypes::Url',
  as 'URI',
  where { 
    my $url = shift;
    return (
      $url->isa('URI') # must be a URI

      && defined($url->scheme) # must have a scheme
      && ($url->scheme() =~ $RE_ALLOWED_SCHEMES)
      && $url->can('host') # must have a host component 
      && $url->can('port') # must respond to port
      && $url->can('default_port') # must respond to default_port
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

