use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Yandex::MailForDomain',
    license             => 'perl',
    dist_author         => q{Oleg Alistratov <ali@ali.org.ua>},
    dist_version_from   => 'lib/WWW/Yandex/MailForDomain.pm',
    build_requires => {
        'Test::More' => 0,
        'LWP::UserAgent' => 0,
        'URI::Escape' => 0,
        'XML::Simple' => 0,
    },
    add_to_cleanup      => [ 'WWW-Yandex-MailForDomain-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
