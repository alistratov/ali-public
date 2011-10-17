use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Crypt::Combined::Digest',
    license             => 'perl',
    dist_author         => q{Oleg Alistratov <zero@cpan.org>},
    dist_version_from   => 'lib/Crypt/Combined/Digest.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Crypt-Combined-Digest-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
