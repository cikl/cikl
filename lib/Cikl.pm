package Cikl;

use 5.014;
use strict;
use warnings;

our $VERSION = '0.4.1';

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
    debug init_logging 
) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw//;

use vars qw($Logger);

=head1 NAME

Cikl - It's new $module

=head1 SYNOPSIS

  use Cikl;

=head1 DESCRIPTION
 
=head1 LICENSE

Copyright (C) 2013 Wes Young (wesyoung.me)
Copyright (C) 2013 REN-ISAC and The Trustees of Indiana University (ren-isac.net)
Copyright (C) 2014 Michael Ryan (github.com/justfalter)

=head1 AUTHOR

Mike Ryan E<lt>falter at gmail.comE<gt>

=head1 Functions

=over

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

=back
=cut

1;
