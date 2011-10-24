#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use strict;
use warnings;
use utf8;

use Test::More 0.88;

use FindBin qw($Bin);
use lib ("$Bin/../../../../lib");

use Crypt::Combined::Digest;

&main();
# ------------------------------------------------------------------------------
sub main
{
    my @tests = (
        {
            name         => 'unicode',
            data         => 'Многабуков',
            salt         => 'Соль',
            alg          => 'unicode',
            size         => 20,
            code         => 'sha1($salt.md5(scalar reverse(sha1($salt.sha1(scalar reverse($salt.sha1(md5($salt.sha1($salt.md5(scalar reverse($salt.md5(md5(md5(sha1(scalar reverse(sha1(md5(scalar reverse($data.$salt)).$salt).$salt)).$salt).$salt).$salt))))).$salt)))).$salt)))',
            slowness     => '33.3',
            bin          => "uy\x82\xD20X>\xB5\x8B\x138\xA1\x82\x8A\x9E\x04\xA7/\xA9k",
            hex          => '757982d230583eb58b1338a1828a9e04a72fa96b',
            b64          => 'dXmC0jBYPrWLEzihgoqeBKcvqWs',
        },
        {
            name         => 'Author',
            data         => 'Олег Алистратов',
            salt         => 'AKA Ali',
            alg          => 'Author',
            size         => 20,
            code         => 'sha1(sha1(sha1(md5($salt.md5(sha1($salt.sha1(sha1(scalar reverse($salt.sha1(md5(scalar reverse(md5(scalar reverse($salt.md5(scalar reverse($salt.$data)))).$salt)).$salt))).$salt)).$salt)).$salt).$salt).$salt)',
            slowness     => '30.7',
            bin          => "\x0CRQ\x20\xB8.\x8B%\xEE{\xE2Cp*\xE5N\xA6\x0F\xF5\x8A",
            hex          => '0c525120b82e8b25ee7be243702ae54ea60ff58a',
            b64          => 'DFJRILguiyXue+JDcCrlTqYP9Yo',
        },
    );

    plan tests => 9 * scalar(@tests);

    my $i = 1;
    for my $t (@tests) {
        my $a = Crypt::Combined::Digest->new($t->{name});
        is($a->alg,         $t->{alg},          "Algorithm $i");
        is($a->size,        $t->{size},         "Size $i");
        is($a->code,        $t->{code},         "Code $i");
        is($a->slowness,    $t->{slowness},     "Slowness $i");

        my $res = $a->hash($t->{data}, $t->{salt});
        is(length($res),    $t->{size},         "Size equal $i");

        is(
            $res,
            $t->{bin},
            "Hash $i"
        );
        is(
            $a->digest($t->{data}, $t->{salt}),
            $t->{bin},
            "Digest $i"
        );
        is(
            $a->hexdigest($t->{data}, $t->{salt}),
            $t->{hex},
            "Hex $i"
        );
        is(
            $a->b64digest($t->{data}, $t->{salt}),
            $t->{b64},
            "Base64 $i"
        );

        $i++;
    }
}
# ------------------------------------------------------------------------------
1;
