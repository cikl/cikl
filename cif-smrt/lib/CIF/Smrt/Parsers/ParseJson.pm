package CIF::Smrt::Parsers::ParseJson;
use base 'CIF::Smrt::Parser';

use JSON;

sub parse {
    my $self = shift;
    my $content_ref = shift;
    my $broker = shift;

    my @feed        = @{from_json($$content_ref)};
    my @fields      = $self->config->fields;
    my @fields_map  = $self->config->fields_map;
    foreach my $a (@feed){
        my $h = $self->create_event($h);
        foreach (0 ... $#fields_map){
            my $v = $a->{$fields[$_]};
            if (defined($v)) {
              $h->{$fields_map[$_]} = lc($v);
            }
        }
        $broker->emit($h);
    }
    return(undef);
}

1;
