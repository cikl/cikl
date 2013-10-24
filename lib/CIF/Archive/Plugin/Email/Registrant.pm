package CIF::Archive::Plugin::Email::Registrant;
use base 'CIF::Archive::Plugin::Email';

use strict;
use warnings;

use Iodef::Pb::Simple qw(iodef_impacts);

__PACKAGE__->table('email_registrant');

use constant EVENT_REGEX => qr/registrant/;

sub assessment_regex {
  return EVENT_REGEX;;
}

sub prepare {
    my $class = shift;
    my $data = shift;
    
    my $impacts = iodef_impacts($data);
    foreach (@$impacts){
        return 1 if($_->get_content->get_content() =~ /registrant/);
    }
    return(0);
}

1;
