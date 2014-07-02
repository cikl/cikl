package Cikl::DataTypes::Integer;
use strict;
use warnings;
use namespace::autoclean;
use Mouse::Util::TypeConstraints;
use constant IS_NUM_RE => qr/^\d+$/;
subtype "Cikl::DataTypes::Integer", 
  as 'Int',
  where { 
    my $v = $_; 
    return (defined($v) && ($v =~ &IS_NUM_RE));
  };

coerce 'Cikl::DataTypes::Integer',
  from 'Defined',
  via { int($_) };

1;
