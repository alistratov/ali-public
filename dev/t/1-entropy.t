#!/usr/bin/perl -w

# ----------------------------------------------------------------------
#
# ----------------------------------------------------------------------

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
# ----------------------------------------------------------------------
sub main
{
    is(password_entropy(undef),	    0, 'Undefined value');

    my %pass = (
        ''                  => 0,
        '1'                 => 4,
        'a'                 => 5,
        '7s'                => 11,
        'abc'               => 12,
        '21920392'          => 21,
        '_S?I'              => 22,
        'pass123'           => 32,
        'ZMHZ0d'            => 33,
        'QGfmyw'            => 35,
        '5dAekE'            => 36,
        '1%Tp_\'oP[viSm&IdGexz'     => 129,
        'g9Hi;4z/X+%nHx?5__v"=fa4"8Tzs>nW:4\'<GE)Qc"}U$@2WN=JQ!G,[7ryVS-3p' => 354,
    );

    plan(tests => 22);

    print "[]-", password_entropy(undef), "\n";

    for my $k (sort(keys(%pass))) {
        print "$k\t", password_entropy($k), "\n";
    }

    #is(password_entropy('pass123'),	0, 'Test 1');
}
# ----------------------------------------------------------------------
1;
