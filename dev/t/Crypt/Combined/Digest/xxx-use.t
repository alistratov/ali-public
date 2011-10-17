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
    #is(password_entropy(undef),	0, 'Undefined value');

    #my $a = Crypt::Combined::Digest->new('testbcdefgh');
    #my $a = Crypt::Combined::Digest->new('4');
    #
    #my $data = 'Ali-Test';
    #my $salt = ''; #'02';
    #
    #print "Descr: ", $a->description, "\n\n";
    #print "Size: ", $a->size, "\n\n";
    ##my $res1 = $a->hexdigest($data, $salt);
    #my $res1 = $a->hexdigest($data);
    #print "Result: ", $res1, "\n\n";
    #
    #use Digest::MD5 qw(md5 md5_hex);
    #use Digest::SHA qw(sha1 sha1_hex);
    #print "Control\n\n";
    #
    #my $res2 = md5_hex(md5('tseT-ilA'));
    ##my $res2 = md5_hex( $salt . md5( reverse( $salt . $data ) ) );
    #print 'X1:', $res2, "\n\n";
    #
    #is($res1, $res2, 'Results are equal');

        #my $a = Crypt::Combined::Digest->new('4');


    my $data = 'da;lkd aksdh sahdjhsdjhd';
    my $a = Crypt::Combined::Digest->new('testbcdefgh');
    print
        "Alg:\t", $a->alg, "\n",
        "Size:\t", $a->size, "\n",
        "Descr:\t", $a->description, "\n",
        "Slow:\t", $a->slowness, "\n",
        '';

    print "BIN:", $a->digest, "\n";
    print "HEX:", $a->hexdigest, "\n";
    print "B64:", $a->b64digest, "\n";
}
# ------------------------------------------------------------------------------

1;
