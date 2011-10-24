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
    my @tests = (
        {
            name         => 'test',
            data         => 'Sample',
            salt         => '',
            alg          => 'test',
            size         => 20,
            code         => 'sha1(sha1(scalar reverse($salt.sha1(md5(scalar reverse($salt.sha1($salt.md5(scalar reverse(sha1(sha1(scalar reverse($salt.$data)).$salt).$salt))))).$salt))).$salt)',
            slowness     => '23.7',
            bin          => "\xEC\x9D\x11?\x13#d&\x83X|\xCB\xB7\xA5\x82\x20\\pCN",
            hex          => 'ec9d113f1323642683587ccbb7a582205c70434e',
            b64          => '7J0RPxMjZCaDWHzLt6WCIFxwQ04',
        },
        {
            name         => 'AlphaZulu-78',
            data         => 'Sample' x 50,
            salt         => 'aX',
            alg          => 'AlphaZulu-78',
            size         => 20,
            code         => 'sha1($salt.md5($salt.md5($salt.sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(md5(scalar reverse(md5(sha1(scalar reverse($salt.sha1(md5(scalar reverse(sha1(scalar reverse(sha1(scalar reverse($salt.sha1($salt.md5(md5(sha1($salt.sha1(sha1($salt.md5(sha1(scalar reverse($salt.md5(scalar reverse($salt.md5(scalar reverse($salt.$data)))))).$salt)).$salt)).$salt).$salt)))).$salt)).$salt)).$salt))).$salt).$salt)).$salt).$salt)).$salt)).$salt)))))',
            slowness     => '61.9',
            bin          => "\xC4\xE7R\x8Dh#\xFF\xD5w\x8B\xB3\xAA\x92\xDD\xFE\x186)\x11\x19",
            hex          => 'c4e7528d6823ffd5778bb3aa92ddfe1836291119',
            b64          => 'xOdSjWgj/9V3i7Oqkt3+GDYpERk',
        },
        {
            name         => 'My own hash',
            data         => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vitae lectus libero, sed sodales erat. Proin scelerisque urna ut nibh semper sagittis. Donec eget dui arcu.',
            salt         => 'foo',
            alg          => 'Myownhash',
            size         => 16,
            code         => 'md5(sha1($salt.sha1(md5(scalar reverse($salt.sha1($salt.md5(md5(sha1($salt.md5(sha1(scalar reverse(md5(scalar reverse($salt.md5($salt.sha1(md5($salt.md5(scalar reverse($salt.md5(md5(scalar reverse(md5($salt.$data).$salt)).$salt)))).$salt)))).$salt)).$salt)).$salt).$salt)))).$salt)).$salt)',
            slowness     => '35.8',
            bin          => "\xE6M\xD9w\x82\x85l\xB1\xD77\x1A\xF9\xA3\x8FI\xE4",
            hex          => 'e64dd97782856cb1d7371af9a38f49e4',
            b64          => '5k3Zd4KFbLHXNxr5o49J5A',
        },
        {
            name         => '0123456789',
            data         => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In feugiat commodo fringilla. Etiam et turpis turpis, a laoreet urna.',
            salt         => '',
            alg          => '0123456789',
            size         => 20,
            code         => 'sha1($salt.sha1($salt.sha1($salt.md5($salt.md5($salt.sha1(scalar reverse(md5($salt.md5(scalar reverse(md5($salt.sha1(scalar reverse($salt.md5($salt.md5(scalar reverse($salt.md5($salt.sha1(md5($salt.md5(md5($salt.sha1($salt.md5($salt.md5($salt.$data)))).$salt)).$salt)))))))).$salt))).$salt)))))))',
            slowness     => '40.2',
            bin          => "\x8Cl\xCB\xCE\x07P\xA7V\x94\x20\x85\xEF\xF7\x9Cq\x85\xD9\xC6\x8F\xF5",
            hex          => '8c6ccbce0750a756942085eff79c7185d9c68ff5',
            b64          => 'jGzLzgdQp1aUIIXv95xxhdnGj/U',
        },
        {
            name         => 'Crypt::Combined::Digest',
            data         => 'Oleg Alistratov',
            salt         => 'zero@cpan.org',
            alg          => 'CryptCombinedDigest',
            size         => 20,
            code         => 'sha1(sha1(scalar reverse($salt.sha1(md5(scalar reverse($salt.sha1($salt.md5(scalar reverse(md5(md5($salt.md5(md5(md5(scalar reverse($salt.sha1(scalar reverse(sha1($salt.sha1(scalar reverse($salt.sha1($salt.md5(scalar reverse(md5(sha1(scalar reverse(md5(md5(sha1($salt.sha1(md5(md5(scalar reverse(sha1(md5($salt.md5(scalar reverse($salt.md5(scalar reverse(sha1(sha1(scalar reverse($salt.sha1(sha1($salt.md5(scalar reverse($salt.md5(sha1(sha1(md5(scalar reverse($salt.md5(scalar reverse($data.$salt)))).$salt).$salt).$salt)))).$salt))).$salt).$salt))))).$salt).$salt)).$salt).$salt)).$salt).$salt).$salt)).$salt).$salt)))))).$salt)))).$salt).$salt)).$salt).$salt))))).$salt))).$salt)',
            slowness     => '88.3',
            bin          => "[#\xA1\xA61\xD8\x8F\xC7\xEC1^\x059\$\x1C\xD5\xA9\xB8\xC0\xE4",
            hex          => '5b23a1a631d88fc7ec315e0539241cd5a9b8c0e4',
            b64          => 'WyOhpjHYj8fsMV4FOSQc1am4wOQ',
        },
        {
            name         => '(X-File)',
            data         => 'All this conjecture about little green men - false, dangerous, delusional.',
            salt         => 'X-F',
            alg          => 'X-File',
            size         => 20,
            code         => 'sha1($salt.md5(scalar reverse(md5(sha1(scalar reverse($salt.md5(md5(sha1(scalar reverse($salt.sha1($salt.sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1($data.$salt).$salt)).$salt)).$salt))))).$salt).$salt))).$salt).$salt)))',
            slowness     => '33.3',
            bin          => "G}\xFEa\x97\xFB\xD8\x14\x85)\x8Fg\xAF\x0E\xEF\xE3=Ouv",
            hex          => '477dfe6197fbd81485298f67af0eefe33d4f7576',
            b64          => 'R33+YZf72BSFKY9nrw7v4z1PdXY',
        },
        {
            name         => '-=-=- [ C00L HaCKer ] -=-=-',
            data         => 'nrfpe94yR2Pura9In1D2GIH12jRpNdqmnCElyxCJUk29eefiPvhFnxwOh3aRdgVF',
            salt         => '2009',
            alg          => '---C00LHaCKer---',
            size         => 20,
            code         => 'sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(sha1(sha1($salt.md5(scalar reverse(sha1(scalar reverse($salt.md5(scalar reverse(md5(scalar reverse($salt.md5(scalar reverse(sha1($salt.md5(sha1(scalar reverse($salt.sha1(sha1(scalar reverse($salt.sha1(scalar reverse(md5($salt.md5($salt.md5($salt.md5($salt.md5(scalar reverse($salt.md5(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse(sha1(scalar reverse($data.$salt)).$salt)).$salt)).$salt)).$salt)).$salt)).$salt)))))))).$salt)))).$salt))).$salt)).$salt)))).$salt)))).$salt))).$salt).$salt).$salt)).$salt)).$salt)).$salt)).$salt)).$salt))',
            slowness     => '89.1',
            bin          => "U\xEEP\xD6\x09\xD9\xAC\x10\xC4\xFC}Fa\x02o\x06\xF0\x97b\xC6",
            hex          => '55ee50d609d9ac10c4fc7d4661026f06f09762c6',
            b64          => 'Ve5Q1gnZrBDE/H1GYQJvBvCXYsY',
        },
        {
            name         => 'nrfpe94yR2Pura9In1D2GIH12jRpNdqmnCElyxCJUk29eefiPvhFnxwOh3aRdgVF',
            data         => 'Time is an illusion. Lunchtime doubly so.',
            salt         => '42',
            alg          => 'nrfpe94yR2Pura9In1D2GIH12jRpNdqmnCElyxCJUk29eefiPvhFnxwOh3aRdgVF',
            size         => 20,
            code         => 'sha1(scalar reverse($salt.sha1($salt.sha1(scalar reverse(sha1($salt.md5(md5($salt.sha1($salt.sha1(scalar reverse($salt.md5(scalar reverse(sha1(scalar reverse($salt.sha1($salt.md5(md5($salt.sha1(md5(sha1($salt.md5(scalar reverse(md5(md5(scalar reverse($salt.md5($salt.md5(scalar reverse($salt.sha1($salt.md5(sha1(scalar reverse(sha1(scalar reverse($salt.sha1($salt.md5(sha1($salt.sha1(sha1(scalar reverse(md5(scalar reverse(sha1(md5(md5(sha1($salt.sha1(scalar reverse(sha1($salt.md5(scalar reverse(sha1($salt.md5(scalar reverse(sha1($salt.sha1($salt.md5($salt.md5(md5(md5(scalar reverse($salt.sha1(scalar reverse(md5($salt.sha1(scalar reverse($salt.sha1(scalar reverse($salt.md5(scalar reverse($salt.md5(scalar reverse(md5(scalar reverse($salt.sha1($salt.md5(scalar reverse($salt.md5(md5(sha1(scalar reverse($salt.sha1(scalar reverse($salt.md5($salt.md5(scalar reverse($salt.md5(scalar reverse(md5(sha1(scalar reverse(md5(md5(scalar reverse(sha1(md5(sha1($salt.sha1(scalar reverse($salt.md5(scalar reverse(sha1($salt.sha1(sha1($salt.md5(scalar reverse(sha1(scalar reverse($salt.md5(sha1(md5($salt.md5(md5($salt.sha1($salt.sha1(scalar reverse($salt.sha1(sha1(scalar reverse($salt.md5(scalar reverse($salt.sha1(scalar reverse($salt.md5(md5($salt.md5(md5(scalar reverse($salt.sha1(scalar reverse(md5($salt.sha1($salt.md5(sha1(scalar reverse(sha1(scalar reverse($salt.md5(scalar reverse($salt.sha1($salt.sha1($salt.sha1($salt.md5(sha1(sha1(sha1(md5(scalar reverse(md5(scalar reverse(sha1(md5($salt.md5(md5(scalar reverse(sha1(scalar reverse($salt.md5(scalar reverse($salt.md5(md5($salt.md5(scalar reverse($salt.sha1($salt.sha1($salt.sha1($salt.md5(scalar reverse(sha1(sha1($salt.sha1($salt.sha1(scalar reverse(sha1(sha1(md5(sha1(scalar reverse($data.$salt)).$salt).$salt).$salt).$salt)))).$salt).$salt)))))))).$salt))))).$salt)).$salt)).$salt).$salt)).$salt)).$salt).$salt).$salt).$salt)))))))).$salt)).$salt))).$salt)))).$salt)).$salt))))))).$salt))))).$salt)).$salt).$salt))).$salt))).$salt)).$salt))))).$salt).$salt).$salt)).$salt).$salt)).$salt).$salt))))))))).$salt).$salt)))))).$salt))))))))).$salt)))).$salt).$salt)))).$salt))).$salt))).$salt))).$salt).$salt).$salt).$salt)).$salt)).$salt)).$salt)))).$salt)).$salt))))))).$salt).$salt))).$salt).$salt)).$salt)))).$salt)))))).$salt)).$salt)))))',
            slowness     => '309.5',
            bin          => "\x06\xC9d\xBBN/\xC1\xFDu\x20\x09\xB3\x08j\xE5t?^M\xAB",
            hex          => '06c964bb4e2fc1fd752009b3086ae5743f5e4dab',
            b64          => 'Bslku04vwf11IAmzCGrldD9eTas',
        },
        {
            name         => '0' x 500,
            data         => 'test',
            salt         => 'aa',
            alg          => '0' x 500,
            size         => 16,
            code         => ('md5($salt.' x 1000) . '$data' . (')' x 1000),
            slowness     => '1190.0',
            bin          => "Q\x1C\xD1\$\xEB\$vX\\7\xEE^\xD0\xAA\xFE\x08",
            hex          => '511cd124eb2476585c37ee5ed0aafe08',
            b64          => 'URzRJOskdlhcN+5e0Kr+CA',
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
