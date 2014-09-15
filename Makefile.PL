use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'LWP::UserAgent::Anonymous',
    AUTHOR             => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM       => 'lib/LWP/UserAgent/Anonymous.pm',
    ABSTRACT_FROM      => 'lib/LWP/UserAgent/Anonymous.pm',
    LICENSE            => 'artistic_2',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Clone'          => 0,
        'LWP::Simple'    => 0,
        'LWP::UserAgent' => 0,
        'HTTP::Request'  => 0,
        'List::Util'     => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'LWP-UserAgent-Anonymous-*' },
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/Manwar/LWP-UserAgent-Anonymous.git',
                web  => 'https://github.com/Manwar/LWP-UserAgent-Anonymous',
            },
        }})
     : ()
    ),
);
