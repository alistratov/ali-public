use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Data::Password::Entropy',
    license             => 'perl',
    dist_author         => q{Oleg Alistratov <zero@cpan.org>},
    dist_version_from   => 'lib/Data/Password/Entropy.pm',
    resources           => {
        repository => 'http://github.com/alien/ali-public/tree/master/modules/Data-Password-Entropy/',
    },
    build_requires => {
        'Test::More' => 0,
        'Encode' => 0,
        'POSIX' => 0,
    },
    add_to_cleanup      => [ 'Data-Password-Entropy-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
