#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use strict;
use warnings;
use utf8;

use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/../../../../lib";

use Data::Password::Entropy;

&main();
# ------------------------------------------------------------------------------
sub main
{
    is(chr(65), 'A', "Is ASCII platform");

    my $warn_thrown = 0;
    local $SIG{__WARN__} = sub {
        my $msg = shift;
        if ($msg =~ /wide/ || $msg =~ /uninitialized/) {
            $warn_thrown = 1;
        }
    };

    is(password_entropy("Хуябрики"), 79, "Wide characters");
    is($warn_thrown, 0, "No warnings");
}
# ------------------------------------------------------------------------------
1;
