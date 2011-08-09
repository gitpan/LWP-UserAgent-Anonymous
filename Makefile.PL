use strict;use warnings;
use ExtUtils::MakeMaker;
WriteMakefile
(
    'NAME'         => 'LWP::UserAgent::Anonymous',
    'VERSION_FROM' => 'lib/LWP/UserAgent/Anonymous.pm',
    'INSTALLDIRS'  => 'site',
    'clean'        => { FILES => 'LWP-UserAgent-Anonymous-*' },
    'PREREQ_PM'    => {
        'Test::More'     => 0,
        'Module::Build'  => '0.36',
        'LWP::UserAgent' => '2.33',
        'List::Util'     => '1.18',
        'Clone'          => '0.31',
        'Net::Telnet'    => '2.36',
    }
);