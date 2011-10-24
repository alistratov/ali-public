package Crypt::Combined::Digest;

use 5.006;
use strict;
use warnings;

=head1 NAME

Crypt::Combined::Digest - The great new Crypt::Combined::Digest!

http://habrahabr.ru/blogs/infosecurity/130965/

http://habrahabr.ru/blogs/crypto/100301/


=head1 VERSION

Version 0.01

=cut


#use Data::Dumper;

use Digest::MD5 qw(md5);
use Digest::SHA qw(sha1);
use MIME::Base64 ();
use Encode qw(encode_utf8);

our $VERSION = '0.01';


use constant LENGTH_MD5  => 16;     # in bytes
use constant LENGTH_SHA1 => 20;

use constant COMPLEXITY_MD5         => 1.00;
use constant COMPLEXITY_SHA1        => 3.25;
use constant COMPLEXITY_CONCAT      => 0.19;
use constant COMPLEXITY_REVERSE     => 0.17;

my $ALLOWED_SYMBOLS = {};

# INIT
{
    my $i = 0;
    $ALLOWED_SYMBOLS->{$_} = $i++ for ('0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_', '-');
}

# ==============================================================================
# Constructor
#
sub new($)
{
    my ($class, $alg) = @_;

    die 'Algorithm not specified' unless defined $alg;
    $alg =~ s/[^0-9a-zA-Z_-]//g;
    die 'Algorithm has the wrong name' if $alg eq '';

    my $self = { alg => $alg };

    my @actions;
    for (split //, $alg) {
        my $x = $ALLOWED_SYMBOLS->{$_};
        #                alg               concat            reverse
        push @actions, [  $x & 0x01,       ($x & 0x02) >> 1, ($x & 0x04) >> 2 ];
        push @actions, [ ($x & 0x08) >> 3, ($x & 0x10) >> 4, ($x & 0x20) >> 5 ];
    }
    $self->{actions} = \@actions;

    # Prepare code, calculate complexity
    my $arg = '$data';
    my $res = '';

    my $cplx_concat  = scalar(@actions);
    my $cplx_md5     = 0;
    my $cplx_sha1    = 0;
    my $cplx_reverse = 0;

    for my $op (@actions) {

        $res = $op->[1] ? "$arg.\$salt" : "\$salt.$arg";

        if ($op->[2]) {
            $res = "scalar reverse($res)";      # or ~~reverse
            $cplx_reverse++;
        }

        if ($op->[0]) {
            $res = "sha1($res)";
            $cplx_sha1++;
        }
        else {
            $res = "md5($res)";
            $cplx_md5++;
        }

        $arg = $res;
    }

    $self->{code} = $res;
    $self->{size} = $actions[$#actions]->[0] ? LENGTH_SHA1 : LENGTH_MD5;

    # Slowness, in comparison with single md5()
    $self->{slowness} = sprintf(
        '%.1f',
        $cplx_md5       * COMPLEXITY_MD5 +
        $cplx_sha1      * COMPLEXITY_SHA1 +
        $cplx_concat    * COMPLEXITY_CONCAT +
        $cplx_reverse   * COMPLEXITY_REVERSE
    );

    # Compile
    my $fullcode = "sub { my (\$data, \$salt) = \@_; return $self->{code}; }";
    $self->{compiled} = eval qq{ $fullcode };

    $self = bless $self, ref($class) || $class;
    return $self;
}
# ------------------------------------------------------------------------------
#
sub alg()           { shift->{alg} }
sub size()          { shift->{size} }
sub code()          { shift->{code} }
sub slowness()      { shift->{slowness} }
# ------------------------------------------------------------------------------
#
sub hash($;$)
{
    my ($self, $data, $salt) = @_;
    $data = '' unless defined $data;
    $salt = '' unless defined $salt;

    my $coderef = $self->{compiled};
    return $coderef->(encode_utf8($data), encode_utf8($salt));
}
# ------------------------------------------------------------------------------
#
sub digest($;$)
{
    return shift->hash(@_);
}
# ------------------------------------------------------------------------------
#
sub hexdigest($;$)
{
    my ($self, $data, $salt) = @_;
    return unpack('H*', $self->hash($data, $salt));
}
# ------------------------------------------------------------------------------
#
sub b64digest($;$)
{
    my ($self, $data, $salt) = @_;
    my $b64 = MIME::Base64::encode($self->hash($data, $salt));
    $b64 =~ s/=+$//g; # remove trailing padding
    $b64 =~ s/\s+$//g;
    return $b64;
}


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Crypt::Combined::Digest;

    my $foo = Crypt::Combined::Digest->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Oleg Alistratov, C<< <zero at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-crypt-combined-digest at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Crypt-Combined-Digest>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 MY COMMENTS

http://en.wikipedia.org/wiki/Crypt_%28Unix%29#MD5-based_scheme
http://httpd.apache.org/docs/2.2/misc/password_encryptions.html

http://insidepro.com/hashes.php?lang=eng

$ openssl speed md5 sha1


A-Z, a-z, 0-9, _, -
26 + 26  + 10 + 2 = 64

543210

0 - md5 || sha1
1 - $data.$salt || $salt.$data
2 - don't reverse || reverse
3 - ..
4 - ..
5 - ..

->new('Name');

->alg
->description
->size (16 or 20)
->slowness

->digest($data, $salt) or ->hash($data, $salt)
->hexdigest
->b64digest


– md5($pass.$salt)
– md5($salt.'-'.md5($pass))
– md5($salt.$pass)
– md5($salt.$pass.$salt)
– md5($salt.$pass.$username)
– md5($salt.md5($pass))
– md5($salt.md5($pass).$salt)
– md5($salt.md5($pass.$salt))
– md5($salt.md5($salt.$pass))
– md5($salt.md5(md5($pass).$salt))
– md5($username.0.$pass)
– md5($username.LF.$pass)
– md5($username.md5($pass).$salt)
– md5(md5($pass))
– md5(md5($pass).$salt)
– md5(md5($pass).md5($salt))
– md5(md5($salt).$pass)
– md5(md5($salt).md5($pass))
– md5(md5($username.$pass).$salt)
– md5(md5(md5($pass)))
– md5(md5(md5(md5($pass))))
– md5(md5(md5(md5(md5($pass)))))
– md5(sha1($pass))
– md5(sha1(md5($pass)))
– md5(sha1(md5(sha1($pass))))
– md5(strtoupper(md5($pass)))
– sha1($pass.$salt)
– sha1($salt.$pass)
– sha1($salt.md5($pass))
– sha1($salt.md5($pass).$salt)
– sha1($salt.sha1($pass))
– sha1($salt.sha1($salt.sha1($pass)))
– sha1($username.$pass)
– sha1($username.$pass.$salt)
– sha1(md5($pass))
– sha1(md5($pass).$salt)
– sha1(md5($pass).$userdate.$salt)
– sha1(md5(sha1($pass)))
– sha1(md5(sha1(md5($pass))))
– sha1(sha1($pass))
– sha1(sha1($pass).$salt)
– sha1(sha1($pass).substr($pass,0,3))
– sha1(sha1($salt.$pass))
– sha1(sha1(sha1($pass)))
– sha1(strtolower($username).$pass)

http://www.insidepro.com/eng/passwordspro.shtml

http://stackoverflow.com/questions/3009988/whats-the-big-deal-with-brute-force-on-hashes-like-md5
http://project-rainbowcrack.com/
http://www.openwall.com/john/



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Crypt::Combined::Digest


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Crypt-Combined-Digest>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Crypt-Combined-Digest>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Crypt-Combined-Digest>

=item * Search CPAN

L<http://search.cpan.org/dist/Crypt-Combined-Digest/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Oleg Alistratov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Crypt::Combined::Digest
