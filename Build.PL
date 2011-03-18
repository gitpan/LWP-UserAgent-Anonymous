use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign               => 1,
    module_name        => 'LWP::UserAgent::Anonymous',
    license            => 'perl',
    dist_author        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from  => 'lib/LWP/UserAgent/Anonymous.pm',
    add_to_cleanup     => [ 'LWP-UserAgent-Anonymous-*' ],
    build_requires     => {
        'Test::More'     => 0,
        'Module::Build'  => 0.36,
        'LWP::UserAgent' => 0,
        'List::Util'     => 0,
        'Clone'          => 0,
        'Net::Telnet'    => 2.36,
    }
);

$builder->create_build_script();