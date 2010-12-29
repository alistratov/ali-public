#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use strict;
use warnings;

use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/../../../../lib";

use_ok('Data::Password::Entropy');

&main();
# ------------------------------------------------------------------------------
sub main
{
    isa_ok('Data::Password::Entropy', 'Exporter');
    is(password_entropy(undef),	0, 'Undefined value');
}
# ------------------------------------------------------------------------------
1;
