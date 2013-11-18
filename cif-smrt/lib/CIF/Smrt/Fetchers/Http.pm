package CIF::Smrt::Fetchers::Http;
use parent CIF::Smrt::Fetcher;

use strict;
use warnings;

our $AGENT = 'cif-smrt/'.$CIF::VERSION.' (collectiveintel.org)';

use constant SCHEMES => qw/http https/;

sub new {
  my $class = shift;
  my $args = shift;
  my $self = $class->SUPER::new($args);

  $self->{timeout} = $args->{timeout} || 300;
  $self->{proxy} = $args->{proxy};
  $self->{verify_tls} = $args->{verify_tls} // 1;
  $self->{feed_user} = $args->{feed_user};
  $self->{feed_password} = $args->{feed_password};
  $self->{mirror} = $args->{mirror};

  return $self;
}

sub schemes { 
  return SCHEMES;
}

sub fetch {
    my $self = shift;
    my $feedurl = shift;
    my $f = shift;
    return unless($feedurl->scheme =~ /^http/);
    return if($f->{'cif'});
    
    # If a proxy server is set in the configuration use LWP::UserAgent
    # since LWPx::ParanoidAgent does not allow the use of proxies
    # We'll assume that the proxy is sane and handles timeouts and redirects and such appropriately.
    # LWPx::ParanoidAgent doesn't work well with Net-HTTP/TLS timeouts just yet
    my $ua;
    if (env_proxy() || $self->{'proxy'} || $feedurl->scheme() eq 'https') {
        # setup the initial agent
        require LWP::UserAgent;
        $ua = LWP::UserAgent->new(agent => $AGENT);
        
        # pull from env_
        $ua->env_proxy();
        
        # if we override, specify
        $ua->proxy(['http','https','ftp'], $self->{'proxy'}) if($self->{'proxy'});
    } else {
        # we use this instead of ::UserAgent, it does better
        # overall timeout checking
        require LWPx::ParanoidAgent;
        $ua = LWPx::ParanoidAgent->new(agent => $AGENT);
    }
    
    $ua->timeout($self->{timeout});
    
    # work-around for what appears to be a threading / race condition
    $ua->max_redirect(0) if($feedurl->scheme() eq 'https');

    if(defined($self->{'verify_tls'} == 0)) {
        $ua->ssl_opts(SSL_verify_mode => 'SSL_VERIFY_NONE');
    } else {
        $ua->ssl_opts(SSL_verify_mode => 'SSL_VERIFY_PEER');
    }
    
    # work-around for a bug in LWP::UserAgent
    delete($ua->{'ssl_opts'}->{'verify_hostname'});

    my $content;
    if($self->{'feed_user'}){
       my $req = HTTP::Request->new(GET => $feedurl->as_string());
       $req->authorization_basic($self->{'feed_user'},$self->{'feed_password'});
       my $ress = $ua->request($req);
       unless($ress->is_success()){
            return('request failed: '.$ress->status_line());
       }
       $content = $ress->decoded_content();
    } else {
        my $r;
        if($self->{'mirror'}){
            $feedurl->path() =~ m/\/([a-zA-Z0-9._-]+)$/;
            my $file = $self->{'mirror'}.'/'.$1;
            return($file.' isn\'t writeable by our user') if(-e $file && !-w $file);
            my $ret = $ua->mirror($feedurl->as_string(),$file);
            # unless it's a 200 or a 304 (which means cached, not modified)
            unless($ret->is_success() || $ret->status_line() =~ /^304 /){
                return $ret->decoded_content();   
            }
            open(F,$file) || return($!.': '.$file);
            $content = join('',<F>);
            close(F);
            return('no content') unless($content && $content ne '');
        } else {
            $r = $ua->get($feedurl->as_string());
            if($r->is_success()){
                $content = $r->decoded_content();
            } else {
                return('failed to get feed: '.$feedurl->as_string()."\n".$r->status_line());
            }
            $ua = undef;
        }
    }
    return(undef,$content);
}

sub env_proxy {
    my ($self) = @_;
    require Encode;
    require Encode::Locale;
    my($k,$v);
    my $found = 0;
    while(($k, $v) = each %ENV) {
        if ($ENV{REQUEST_METHOD}) {
            # Need to be careful when called in the CGI environment, as
            # the HTTP_PROXY variable is under control of that other guy.
            next if $k =~ /^HTTP_/;
            $k = "HTTP_PROXY" if $k eq "CGI_HTTP_PROXY";
        }
        $k = lc($k);
        next unless $k =~ /^(.*)_proxy$/;
        $k = $1;
        unless($k eq 'no') {
            # Ignore random _proxy variables, allow only valid schemes
            next unless $k =~ /^$URI::scheme_re\z/;
            # Ignore xxx_proxy variables if xxx isn't a supported protocol
            next unless LWP::Protocol::implementor($k);
            $found = 1;
        }
    }
    return $found;
}
1;
