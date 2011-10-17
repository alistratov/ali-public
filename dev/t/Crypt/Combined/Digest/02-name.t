#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use strict;
use warnings;

use Test::More 0.88;

use FindBin qw($Bin);
use lib ("$Bin/../../../../lib");

use Crypt::Combined::Digest;

&main();
# ------------------------------------------------------------------------------
sub main
{
    my @wrong = (
        '',
        ' ',
        '...',
        '~!',
        "\n\t\r",
        'Абырвалг'
    );

    my @trim = (
        [ 'Oleg Alistratov',        'OlegAlistratov' ],
        [ ' lorem ipsum ... ',      'loremipsum' ],
        [ '2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97', '2357111317192329313741434753596167717379838997' ],
        [ 'O(k · log3 n)',          'Oklog3n' ],
        [ 'Чернобыль-2',            '-2' ],
        [ 'AZRK_29 RAND()',         'AZRK_29RAND' ],
    );

    plan tests => 1 + scalar(@wrong) + scalar(@trim);

    eval {
        my $a = Crypt::Combined::Digest->new();
    };
    ok($@ && $@ =~ /^Algorithm not specified/, 'Algorithm not specified');

    for (my $i = 1; $i <= @wrong; $i++) {
        eval {
            my $a = Crypt::Combined::Digest->new( $wrong[ $i - 1 ] );
        };
        ok($@ && $@ =~ /^Algorithm has the wrong name/, "Algorithm has the wrong name $i");
    }

    for (my $i = 1; $i <= @trim; $i++) {
        my $a = Crypt::Combined::Digest->new( $trim[ $i - 1 ]->[0] );
        is($a->alg, $trim[ $i - 1 ]->[1], "Algorithm name was truncated $i");
    }
}
# ------------------------------------------------------------------------------
1;
