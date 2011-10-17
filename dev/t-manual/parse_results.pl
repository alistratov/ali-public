#!/usr/bin/perl -w
# -*- coding: UTF-8 -*-

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use warnings;
use strict;

use Data::Dumper;

&main();
# ------------------------------------------------------------------------------
sub main
{
    my @data;

    open(my $fh, '<results-16.txt');

    my $elem = {};
    while (my $line = <$fh>) {

        if ($line =~ /^\s+Rate/) {

            push(@data, $elem) if $elem->{MD5};
            $elem = {};

        }
        elsif ($line =~ /^(\w\w\w)\s+(\d+)\/s/) {
            $elem->{$1} = $2;
        }

    }

    close($fh);

    print "MD5\tSHA1\tCon\tRev\n";
    for my $d (@data) {
        $d->{Con} = '-' if ! $d->{Con};
        print "$d->{MD5}\t$d->{SHA}\t$d->{Con}\t$d->{Rev}\n";
    }

    #print Dumper(\@data);
}
# ------------------------------------------------------------------------------
1;
