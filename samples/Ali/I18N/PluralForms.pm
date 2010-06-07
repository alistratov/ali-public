package Ali::I18N::PluralForms;

use strict;
use warnings;
use utf8;

use vars qw($VERSION);
$VERSION = "1.5";

use Carp;
# ------------------------------------------------------------------------------

=head1 NAME

C<Ali::I18N::PluralForms> - functions for plural form selection.

=head1 SYNOPSIS

    my $plural = Ali::I18N::PluralForms::plural_func('ru');
    my $idx = &$plural($n); # return 2 for $n == 5
    print sprintf(('Найден %d документ', 'Надено %d документа', 'Найдено %d документов')[$idx], $n), "\n";

=cut

# ------------------------------------------------------------------------------

=head1 DESCRIPTION

=head2 Methods

=over

=item plural_func( $language )

Accept language code as it's in IANA Language Subtag Registry:
http://www.iana.org/assignments/language-subtag-registry
Returns subref.

=cut

# ------------------------------------------------------------------------------
sub plural_func
{
    my ($lang) = @_;
    my $r = undef;

    # Russian, Ukrainian, Belarusian, Croatian, Serbian
    if ($lang eq 'ru' || $lang eq 'uk' || $lang eq 'be' || $lang eq 'hr' || $lang eq 'sr') {
        $r = sub {
            my $n = shift;
            $n = -$n if $n < 0;
            # nplurals = 3
            return $n % 10 == 1 && $n % 100 != 11 ? 0 :
                    $n % 10 >= 2 && $n % 10 <= 4 && ($n % 100 < 10 || $n % 100 >= 20) ? 1 : 2;
        }
    }
    # Japanese, Chinese, Korean, Vietnamese, Turkish
    elsif ($lang eq 'ja' || $lang eq 'zh' || $lang eq 'ko' || $lang eq 'vi' || $lang eq 'tr') {
        $r = sub {
            my $n = shift;
            # nplurals = 1
            return 0;
        }
    }
    # French, Brazilian Portuguese (Creoles and pidgins)
    elsif ($lang eq 'fr' || $lang eq 'cpf' || $lang eq 'cpp') {
        $r = sub {
            my $n = shift;
            # nplurals = 2
            return $n > 1 ? 1 : 0;
        }
    }
    # Polish
    elsif ($lang eq 'pl') {
        $r = sub {
            my $n = shift;
            # nplurals = 3
            return $n == 1 ? 0 :
                    $n % 10 >= 2 && $n % 10 <= 4 && ($n % 100 < 10 || $n % 100 >= 20) ? 1 : 2;
        }
    }
    # Slovak, Czech
    elsif ($lang eq 'sk' || $lang eq 'cs') {
        $r = sub {
            my $n = shift;
            # nplurals = 3
            return ($n == 1) ? 0 : ($n >= 2 && $n <= 4) ? 1 : 2;
        }
    }
    # Slovenian
    elsif ($lang eq 'sl') {
        $r = sub {
            my $n = shift;
            # nplurals = 4
            return $n % 100 == 1 ? 0 : $n % 100 == 2 ? 1 : $n % 100 == 3 || $n % 100 == 4 ? 2 : 3;
        }
    }
    # Romanian
    elsif ($lang eq 'ro') {
        $r = sub {
            my $n = shift;
            # nplurals = 3
            return $n == 1 ? 0 : ($n == 0 || ($n % 100 > 0 && $n % 100 < 20)) ? 1 : 2;
        }
    }
    # Latvian
    elsif ($lang eq 'lv') {
        $r = sub {
            my $n = shift;
            # nplurals = 3
            return $n % 10 == 1 && $n % 100 != 11 ? 0 : $n != 0 ? 1 : 2;
        }
    }
    # Lithuanian
    elsif ($lang eq 'lt') {
        $r = sub {
            my $n = shift;
            # nplurals = 3
            return $n % 10 == 1 && $n % 100 != 11 ? 0 :
                    $n %10 >= 2 && ($n % 100 < 10 || $n % 100 >= 20) ? 1 : 2;
        }
    }
    # Arabic
    elsif ($lang eq 'ar') {
        $r = sub {
            my $n = shift;
            # nplurals = 6
            return $n == 0 ? 0 : $n == 1 ? 1 : $n == 2 ? 2 : $n >= 3 && $n <= 10 ? 3 : $n >= 11 && $n <= 99 ? 4 : 5;
        }
    }
    # Gaeilge (Irish)
    elsif ($lang eq 'ga') {
        $r = sub {
            my $n = shift;
            # nplurals = 3
            return $n == 1 ? 0 : $n == 2 ? 1 : 2;
        }
    }
    # Default: English and other ... Danish, Dutch, Faroese, German, Norwegian, Swedish,
    # Estonian, Finnish, Greek, Hebrew, Italian, Portuguese, Spanish, Esperanto
    else {
        $r = sub {
            my $n = shift;
            # nplurals = 2
            return $n != 1 ? 1 : 0;
        }
    }

    return $r;
}
# ------------------------------------------------------------------------------\

=back

=head1 COPYRIGHT

Copyright 2007-2010 Oleg Alistratov

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# ------------------------------------------------------------------------------\
1;
