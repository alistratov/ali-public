#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use strict;
use warnings;

use Test::More;

use FindBin qw($Bin);
use lib ("$Bin/../lib");

BEGIN
{
    use_ok('Data::Password::Entropy');
    isa_ok('Data::Password::Entropy', 'Exporter');
}

&main();
# ------------------------------------------------------------------------------
sub main
{
    plan(3);

    is(password_entropy(undef),	0, 'Undefined value');
}
# ------------------------------------------------------------------------------
1;
