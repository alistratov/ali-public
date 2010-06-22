package Data::Password::Entropy;
# coding: UTF-8

use utf8;
use strict;
use warnings;

use Encode;
use POSIX qw(ceil);

our $VERSION = '0.01';

# ==============================================================================

use Exporter;
use base qw(Exporter);
our @EXPORT = qw(
    password_entropy
);
# ==============================================================================
sub password_entropy($)
{
    my ($passw) = @_;

    my $entropy = 0;

    if (defined($passw) && $passw ne '') {

        # Convert to octets
        $passw = Encode::encode_utf8($passw);

        my $base = {
            lower           => 0,
            upper           => 0,
            number          => 0,
            special_simple  => 0,
            special_ext     => 0,
            escape          => 0,
            high            => 0,
        };
        my $base_high = +{};

        my $effective_len = 0.0;
        my $char_counts = +{};
        my $diff = +{};

        my $prev_nc = 0;

        my @chars = split(//, $passw);
        my $len = scalar(@chars);

        for (my $i = 0; $i < $len; $i++) {
            my $c = $chars[$i];
            my $nc = ord($c);

            if ($nc < ord(' ')) {
                $base->{escape} = 1;
            }
            elsif ($nc >= ord('A') && $nc <= ord('Z')) {
                $base->{upper} = 1;
            }
            elsif ($nc >= ord('a') && $nc <= ord('z')) {
                $base->{lower} = 1;
            }
            elsif ($nc >= ord('0') && $nc <= ord('9')) {
                $base->{number} = 1;
            }
            elsif ($nc >= ord(' ') && $nc <= ord('/')) {
                $base->{special_simple} = 1;
            }
            elsif ($nc > 127) { # > DEL, was ord('~')
                $base->{high} = 1;
            }
            else {
                $base->{special_ext} = 1;
            }

            my $diff_fact = 1.0;

            if ($i > 0) {
                my $d = $nc - $prev_nc;

                if (exists($diff->{$d})) {
                    $diff->{$d}++;
                    $diff_fact /= $diff->{$d};
                }
                else {
                    $diff->{$d} = 1;
                }
            }

            if (exists($char_counts->{$c})) {
                $char_counts->{$c}++;
                $effective_len += $diff_fact * (1.0 / $char_counts->{$c});
            }
            else {
                $char_counts->{$c} = 1;
                $effective_len += $diff_fact;
            }

            $prev_nc = $nc;

            my $char_space = 0;
            $char_space +=  32 if ($base->{escape});
            $char_space +=  26 if ($base->{upper});
            $char_space +=  26 if ($base->{lower});
            $char_space +=  10 if ($base->{number});
            $char_space +=  16 if ($base->{special_simple});
            $char_space +=  18 if ($base->{special_ext});
            $char_space += 128 if ($base->{high});

            if ($char_space != 0) {
                my $bits_per_char = log($char_space) / log(2.0);
                $entropy = ceil($bits_per_char * $effective_len);
            }
        }
    }

    return $entropy;
}
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
of a password in resisting guessing and brute-force attacks
[...]

We use a very simple, empirical algorithm to find a password entropy.
All symbols from string splits into several classes, such as numbers, lower- or
upper-case letters and so on. Probability

Be careful: an algorithm does not check password weakness with dictionary lookup.

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

=head1 COPYRIGHT

Copyright (c) 2010 Oleg Alistratov. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=head1 AUTHOR

Oleg Alistratov <zero@cpan.org>

=cut
