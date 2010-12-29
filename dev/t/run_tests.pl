#!/usr/bin/perl -w
# coding: UTF-8

use strict;
use warnings;

use TAP::Harness;
use File::Find;
use Getopt::Long;
use FindBin;

&main();
# ------------------------------------------------------------------------------
sub main
{
    my $lasttm = undef; # in days
    GetOptions( 'last|l:f' => \$lasttm );
    
    if (!defined($lasttm)) {
        print "Do all tests.\n";
    }
    else {
        $lasttm = 1 if ($lasttm <= 0);
        my $d = int($lasttm);
        my $h = ($lasttm - $d) * 24;
        
        print "Do tests for the last" .
              ($d != 0 ? " $d day(s)" : '') .
              ($h != 0.0 ? " $h hour(s)" : '') .
              "\n";
    }
    
    my $harness = TAP::Harness->new({
        verbosity => 0,
        lib       => [ "$FindBin::Bin/", "$FindBin::Bin/../lib" ],
    });

    my (@tests) = ();
    find(
        sub {
            if ($File::Find::name =~ /\.t$/ && (!defined($lasttm) || -M $File::Find::name <= $lasttm)) {
                push(@tests, $File::Find::name);
            }
        },
        ($FindBin::Bin)
    );

    $harness->runtests(sort(@tests));
}
# ==============================================================================
1;
