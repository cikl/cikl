package CIF::Client::HTTPCommonTransport;
use base 'CIF::Client::Transport';

use strict;
use warnings;

use CIF qw/debug/;
require LWP::UserAgent;
use Try::Tiny;
use JSON::XS;
use CIF::MsgHelpers;

our $AGENT = 'libcif/'.$CIF::VERSION.' (collectiveintel.org)';

sub new {
    my $class = shift;
    my $args = shift;

    my $self = $class->SUPER::new($args);

    $self->{'ua'} = $self->_init_useragent();
    
    return($self);
}

sub _init_useragent {
    my $self = shift;

    my $ua = LWP::UserAgent->new();
     
    # seems to be a bug if you don't set this
    $ua->{'max_redirect'}    = $self->get_config->{'max_redirect'} || 5;

    if(defined($self->get_config->{'verify_tls'}) && $self->get_config->{'verify_tls'} == 0){
        $ua->ssl_opts(SSL_verify_mode => 'SSL_VERIFY_NONE');
        $ua->ssl_opts(verify_hostname => 0);
    }

    # set proxy
    # eg: export http_proxy='http://localhost:5050'
    $ua->env_proxy();

    # override
    if($self->get_config->{'proxy'}){
        debug('setting proxy') if($::debug);
        $ua->proxy(['http','https'],$self->get_config->{'proxy'});
    }
    
    $ua->agent($AGENT);
    
    my $cache = $self->get_config->{'total_capacity'} || 5;
    $ua->conn_cache({ total_capacity => $cache });
    
    my $timeout = $self->get_config->{'timeout'} || 300;
    $ua->timeout($timeout);

    return($ua);
}

sub _http_post {
    my $self = shift;
    my $data = shift;
    return unless($data);
    
    my ($err,$ret);
    my $x = 0;
    
    do {
        debug('posting data...') if($::debug);
        try {
            $ret = $self->{'ua'}->post($self->get_config->{'host'},Content => $data);
        } catch {
            $err = shift;
        };
        if($err){
            for(lc($err)){
                if(/^server closed connection/){
                    debug('server closed the connection, retrying...') if($::debug);
                    $err = undef;
                    sleep(5);
                    last;
                }
                if(/connection refused/){
                    debug('server connection refused, retrying...') if($::debug);
                    $err = undef;
                    sleep(5);
                    last;
                }
                $x = 5;
            }
        }
    } while(!$ret && ($x++ < 5));
    ## TODO -- do we turn this into a re-submit?
    return('unknown, possible server timeout....') unless($ret);
    return($ret->status_line()) unless($ret->is_success());
    debug('data sent succesfully...') if($::debug);
    return(undef,$ret->decoded_content());
}

1;
