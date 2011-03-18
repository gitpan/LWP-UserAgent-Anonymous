use strict;use warnings;
use ExtUtils::MakeMaker;
WriteMakefile
(
    'NAME'         => 'LWP::UserAgent::Anonymous',
    'VERSION_FROM' => 'lib/LWP/UserAgent/Anonymous.pm',
    'INSTALLDIRS'  => 'site',
    'clean'        => { FILES => 'LWP-UserAgent-Anonymous-*' },
    'PREREQ_PM'    => {
        'Clone'          => '0',
        'LWP::UserAgent' => '0',
        'List::Util'     => '0',
        'Module::Build'  => '0.36',
        'Net::Telnet'    => '2.36',
        'Test::More'     => '0'
    }
);