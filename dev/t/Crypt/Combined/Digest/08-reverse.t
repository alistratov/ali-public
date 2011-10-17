#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use strict;
use warnings;

use Test::More 0.88 tests => 1;

use FindBin qw($Bin);
use lib ("$Bin/../../../../lib");

use Crypt::Combined::Digest;

&main();
# ------------------------------------------------------------------------------
sub main
{
    my $a = Crypt::Combined::Digest->new('0');  # double md5
    my $r = Crypt::Combined::Digest->new('4');  # double md5 with reversed data

    is(
        $a->hexdigest('baz'),
        $r->hexdigest('zab'),
        'Reversed argument'
    );
}
# ------------------------------------------------------------------------------
1;
