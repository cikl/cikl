package CIF::MooseTypes;
use strict;
use warnings;
use Moose::Util::TypeConstraints;
use CIF qw(is_uuid);


subtype "CIF::MooseTypes::LowerCaseStr", 
  as 'Str',
  where { !/\p{Upper}/ms },
  message { "Must be lowercase." };

coerce 'CIF::MooseTypes::LowerCaseStr',
  from 'Str',
  via { lc };

subtype "CIF::MooseTypes::LowercaseUUID", 
  as 'Str',
  where { is_uuid($_) && ($_ !~ /[A-Z]/) },
  message { "Not a UUID with all lower-case characters: " . $_ };

subtype "CIF::MooseTypes::PortList", 
  as 'Str',
  where {
    my $portlist = shift;
    foreach my $part (split(',', $portlist)) {
      if ($part =~ /^(\d+)(?:-(\d+))?$/) {
        my $start = $1;

        # No end? Just use the start as the end.
        my $end = $2 || $start; 

        # The start should come before the end...
        if (($start > $end) ||
            ($start < 0 || $start > 65535) ||
            ($end < 0 || $end > 65535)) { 
          return 0;
        }
      } else {
        return 0;
      }
    }
    return 1;
  };

1;
