package Cikl;

use 5.014;
use strict;
use warnings;

our $VERSION = '0.4.1';

use UUID::Tiny;
use DateTime;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration   use Cikl::Utils ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
    is_uuid generate_uuid_random generate_uuid_url generate_uuid_hash 
    generate_uuid_ns debug init_logging 
) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw//;

use constant UUID_RE => qr/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

use vars qw($Logger);

=head1 NAME

Cikl - It's new $module

=head1 SYNOPSIS

  use Cikl;

=head1 DESCRIPTION
 
  These are mostly helper functions to be used within Cikl::Archive. We did some extra work to better parse timestamps and provide some internal uuid, cpu throttling and thread-batching for various Cikl functions.

=head1 LICENSE

Copyright (C) 2013 Wes Young (wesyoung.me)
Copyright (C) 2013 REN-ISAC and The Trustees of Indiana University (ren-isac.net)
Copyright (C) 2014 Michael Ryan (github.com/justfalter)

=head1 AUTHOR

Mike Ryan E<lt>falter at gmail.comE<gt>

=head1 Functions

=over

=item is_uuid($uuid)

  Returns 1 if the argument matches /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  Returns 0 if it doesn't

=cut

sub is_uuid {
    return(($_[0] && $_[0] =~ UUID_RE) ? 1 : undef);
}

=item debug($string)

  outputs debug information when called

=cut

## TODO -- clean this and init_logging up

sub debug {
    return unless($::debug);

    my $msg = shift;
    my ($pkg,$f,$line,$sub) = caller(1);
    
    unless($f){
        ($pkg,$f,$line) = caller();
    }
    
    $sub = '' unless($sub);
    my $ts = DateTime->from_epoch(epoch => time());
    $ts = $ts->ymd().'T'.$ts->hms().'Z';
    
    if($Cikl::Logger){
         if($::debug > 5){
            $Cikl::Logger->debug("[DEBUG][$ts][$f:$sub:$line]: $msg");
        } elsif($::debug > 1) {
            $Cikl::Logger->debug("[DEBUG][$ts][$sub]: $msg");
        } else {
            $Cikl::Logger->debug("[DEBUG][$ts]: $msg");
        }
    } else {
        if($::debug > 5){
            print("[DEBUG][$ts][$f:$sub:$line]: $msg\n");
        } elsif($::debug > 1) {
            print("[DEBUG][$ts][$sub]: $msg\n");
        } else {
            print("[DEBUG][$ts]: $msg\n");
        }
    }
}

sub init_logging {
    my $d = shift;
    return unless($d);
    
    $::debug = $d;
    require Log::Dispatch;
    unless($Cikl::Logger){
        $Cikl::Logger = Log::Dispatch->new();
        require Log::Dispatch::Screen;
        $Cikl::Logger->add( 
            Log::Dispatch::Screen->new(
                name        => 'screen',
                min_level   => 'debug',
                stderr      => 1,
                newline     => 1
             )
        );
    }
}   

=item generate_uuid()

  generates a random "v4" uuid and returns it as a string

=cut

sub generate_uuid_random {
    return(create_UUID_as_string(UUID_V4));
}

sub generate_uuid_ns {
    my $source = shift;
    # NOTE: This isn't actually generating a URL namespaced UUID! There was 
    # a bug in the original Cikl implementation that caused it to generate 
    # with a 'nil' namespace UUID. If we 'fix' this, it'll break existing 
    # repositories. 
    ## return(create_UUID_as_string(UUID_V3, UUID_NS_URL, $source));
    #
    # Instead, we generate using a nil namespace:
    return(create_UUID_as_string(UUID_V3, $source));
}

# deprecate
sub generate_uuid_url {
    return generate_uuid_ns(shift);
}

=back
=cut

1;