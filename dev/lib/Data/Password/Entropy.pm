package Data::Password::Entropy;
# coding: UTF-8

use utf8;
use strict;
use warnings;

use Encode;
use POSIX qw(floor);

our $VERSION = '0.03';

# ==============================================================================

use Exporter;
use base qw(Exporter);
our @EXPORT = qw(
    password_entropy
);
# ==============================================================================
use constant {
    CONTROL         => 0,
    NUMBER          => 1,
    UPPER           => 2,
    LOWER           => 3,
    PUNCT_1         => 4,
    PUNCT_2         => 5,
    EXTENDED        => 6,
};

my @CHAR_CLASSES;
my %CHAR_CAPACITY;

BEGIN
{
    for my $i (0..255) {
        my $cclass = 0;

        if ($i < 32) {
            $cclass = CONTROL;
        }
        elsif ($i >= ord('0') && $i <= ord('9')) {
            $cclass = NUMBER;
        }
        elsif ($i >= ord('A') && $i <= ord('Z')) {
            $cclass = UPPER;
        }
        elsif ($i >= ord('a') && $i <= ord('z')) {
            $cclass = LOWER;
        }
        elsif ($i > 127) {
            $cclass = EXTENDED;
        }
        elsif (
            # Simple punctuation marks, which can be typed with first row of keyboard or numpad
            $i == 32 ||          # space
            $i == ord('!') ||    # 33
            $i == ord('@') ||    # 64
            $i == ord('#') ||    # 35
            $i == ord('$') ||    # 36
            $i == ord('%') ||    # 37
            $i == ord('^') ||    # 94
            $i == ord('&') ||    # 38
            $i == ord('*') ||    # 42
            $i == ord('(') ||    # 40
            $i == ord(')') ||    # 41
            $i == ord('_') ||    # 95
            $i == ord('+') ||    # 43
            $i == ord('-') ||    # 45
            $i == ord('=') ||    # 61
            $i == ord('/')       # 47
        ) {
            $cclass = PUNCT_1;
        }
        else {
            # Other punctuation marks
            $cclass = PUNCT_2;
        }

        $CHAR_CLASSES[$i] = $cclass;
        if (!$CHAR_CAPACITY{$cclass}) {
            $CHAR_CAPACITY{$cclass} = 1;
        }
        else {
            $CHAR_CAPACITY{$cclass}++;
        }
    }
}
# ==============================================================================
sub password_entropy($)
{
    my ($passw) = @_;

    my $entropy = 0;

    if (defined($passw) && $passw ne '') {

        # Convert to octets
        $passw = Encode::encode_utf8($passw);

        my $classes = +{};

        my $eff_len = 0.0;      # the effective length
        my $char_count = +{};   # to count characters quantities
        my $distances = +{};    # to collect differences between adjacent characters

        my $len = length($passw);

        my $prev_nc = 0;

        for (my $i = 0; $i < $len; $i++) {
            my $c = substr($passw, $i, 1);
            my $nc = ord($c);
            $classes->{$CHAR_CLASSES[$nc]} = 1;

            my $incr = 1.0;     # value/factor for increment effective length

            if ($i > 0) {
                my $d = $nc - $prev_nc;

                if (exists($distances->{$d})) {
                    $distances->{$d}++;
                    $incr /= $distances->{$d};
                }
                else {
                    $distances->{$d} = 1;
                }
            }

            if (exists($char_count->{$c})) {
                $char_count->{$c}++;
                $eff_len += $incr * (1.0 / $char_count->{$c});
            }
            else {
                $char_count->{$c} = 1;
                $eff_len += $incr;
            }

            $prev_nc = $nc;
        }

        my $pci = 0;            # Password complexity index
        for (keys(%$classes)) {
            $pci += $CHAR_CAPACITY{$_};
        }

        if ($pci != 0) {
            my $bits_per_char = log($pci) / log(2.0);
            $entropy = floor($bits_per_char * $eff_len);
        }
    }

    return $entropy;
}
# ------------------------------------------------------------------------------
# ==============================================================================
1;
__END__

=head1 NAME

Data::Password::Entropy - Calculate password strength

=head1 SYNOPSIS

    use Data::Password::Entropy;
    print "Entropy is ", password_entropy("pass123"), " bits.\n";


=head1 DESCRIPTION

Entropy, also known as password quality or password strength, is a measure
of a password in resisting guessing and brute-force attacks.
[...]

We use a very simple, empirical algorithm to find a password entropy.
All characters from string splits into several classes, such as numbers,
lower- or upper-case letters and so on. Probability [...]

C<'abcd'> is weaker than C<'adbc'>

C<'a' x 100> insignificantly stronger than C<'a' x 4>


Do not expect too much: an algorithm does not check password weakness
with dictionary lookup.

The character classes based on the ASCII encoding. If you have something else,
e.g. EBCDIC, you can try something like the L<Convert::EBCDIC> module.

=head1 FUNCTIONS

There is only one function in this package and it is exported by default.

=over

=item C<password_entropy($str)>

Returns an entropy of C<$str>, calulating in bits.

Argument is treated as a byte-string, not a wide-character string,
so any characters with codes higher than 127 [...]

Note: one possible way to process wide characters underlies in determining
character's Unicode script or Unicode block, and use them capacity as base for
calculating [...]

=back


=head1 SEE ALSO

L<Data::Password::Manager>, L<Data::Password>, L<Data::Password::BasicCheck>.

L<http://en.wikipedia.org/wiki/Password_strength>

A Conceptual Framework for Assessing Password Quality, PDF
L<http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.98.3266&rep=rep1&type=pdf>

=head1 COPYRIGHT

Copyright (c) 2010 Oleg Alistratov. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=head1 AUTHOR

Oleg Alistratov <zero@cpan.org>

=cut
