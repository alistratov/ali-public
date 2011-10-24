#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib ("$Bin/../../../../lib");

use Crypt::Combined::Digest;

&main();
# ------------------------------------------------------------------------------
sub main
{
    my @tests = (
        {
            name        => 'test',
            data        => 'Sample',
            salt        => '',
        },
        {
            name        => 'AlphaZulu-78',
            data        => 'Sample' x 50,
            salt        => 'aX',
        },
        {
            name        => 'My own hash',
            data        => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vitae lectus libero, sed sodales erat. Proin scelerisque urna ut nibh semper sagittis. Donec eget dui arcu.',
            salt        => 'foo',
        },
        {
            name        => '0123456789',
            data        => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In feugiat commodo fringilla. Etiam et turpis turpis, a laoreet urna.',
            salt        => '',
        },
        {
            name        => 'Crypt::Combined::Digest',
            data        => 'Oleg Alistratov',
            salt        => 'zero@cpan.org',
        },
        {
            name        => '(X-File)',
            data        => 'All this conjecture about little green men - false, dangerous, delusional.',
            salt        => 'X-F',
        },
        {
            name        => '-=-=- [ C00L HaCKer ] -=-=-',
            data        => 'nrfpe94yR2Pura9In1D2GIH12jRpNdqmnCElyxCJUk29eefiPvhFnxwOh3aRdgVF',
            salt        => '2009',
        },
        {
            name        => 'nrfpe94yR2Pura9In1D2GIH12jRpNdqmnCElyxCJUk29eefiPvhFnxwOh3aRdgVF',
            data        => 'Time is an illusion. Lunchtime doubly so.',
            salt        => '42',
        },
        {
            name        => '0' x 500,
            data        => 'test',
            salt        => 'aa',
        },
        {
            name        => 'unicode',
            data        => 'Многабуков',
            salt        => 'Соль',
        },
        {
            name        => 'Author',
            data        => 'Олег Алистратов',
            salt        => 'AKA Ali',
        },
    );

    for my $t (@tests) {
        my $a = Crypt::Combined::Digest->new($t->{name});

        print "{\n";

        print "    name         => '$t->{name}',\n";
        print "    data         => '$t->{data}',\n";
        print "    salt         => '$t->{salt}',\n";

        print "    alg          => '" . $a->alg . "',\n";
        print "    size         => " . $a->size . ",\n";
        print "    code         => '" . $a->code . "',\n";
        print "    slowness     => '" . $a->slowness . "',\n";

        print "    bin          => \"" . escape($a->hash( $t->{data}, $t->{salt} )) . "\",\n";
        print "    hex          => '" . $a->hexdigest( $t->{data}, $t->{salt} ) . "',\n";
        print "    b64          => '" . $a->b64digest( $t->{data}, $t->{salt} ) . "',\n";

        print "},\n";
    }
}
# ------------------------------------------------------------------------------
sub escape
{
    my ($a) = @_;
    my $r = '';

    my @sym = split //, $a;

    for my $s (@sym) {
        my $n = ord($s);
        if ($s eq '\\' || $s eq '$' || $s eq '@') {
            $r .= '\\' . $s;
        }
        elsif ($n <= 0x20 || $n >= 127) {
            $r .= '\x' . sprintf('%02X', $n);
        }
        else {
            $r .= $s;
        }
    }

    return $r;
}
# ------------------------------------------------------------------------------
1;
