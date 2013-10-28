package CIF::Archive::Helpers;

use warnings;
use strict;

use Digest::SHA qw/sha1_hex/;

our @ISA = 'Exporter';
our @EXPORT_OK = qw/
generate_sha1_if_needed
is_sha1
is_email
/;

sub is_sha1 {
    my $thing = shift;
    if (!defined($thing)) {
      die("Not defined");
    } elsif (ref($thing)) {
      die("Not a scalar");
    }

    if (lc($thing) =~ /^[a-f0-9]{40}$/) {
      return 1;
    }
    return 0;
}

sub generate_sha1_if_needed {
    my $thing   = shift;
    if (is_sha1($thing)) {
      return $thing;
    }
    return sha1_hex($thing);
}

sub is_email {
    my $e = shift;
    return unless($e);
    return if($e =~ /^(ftp|https?):\/\//);
    return unless(lc($e) =~ /^([\w+.-_]+\@[a-z0-9.-]+\.[a-z0-9.-]{2,8})$/);
    return(1);
}

