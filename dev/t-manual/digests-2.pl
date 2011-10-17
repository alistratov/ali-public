#!/usr/bin/perl -w
# -*- coding: UTF-8 -*-

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use warnings;
use strict;

use Benchmark qw(:all);

use Digest::MD5 qw(md5);
use Digest::SHA qw(sha1);

&main();
# ------------------------------------------------------------------------------
sub main
{
    my $TIMES = 10_000_000;

    my $S = 16;                 # size of data

    # Prepare data
    my $data = pack('C*', map { rand(256) } ( 1 .. $S ));

    cmpthese($TIMES,
        {
            'MD5'   =>  sub { md5($data) },
            'SHA'   =>  sub { sha1($data) },
            'Rev'   =>  sub { scalar reverse $data },
            'Con'   =>  sub { $data . $data },
        }
    );
}
# ------------------------------------------------------------------------------
1;
