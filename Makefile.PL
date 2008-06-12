#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'POE::Component::Supervisor',
	VERSION_FROM => 'lib/POE/Component/Supervisor.pm',
	INSTALLDIRS  => 'site',
	SIGN         => 1,
	PL_FILES     => { },
	PREREQ_PM    => {
		'Test::use::ok' => 0,
        'POE' => 0,
        'MooseX::POE' => 0,
        'MooseX::LogDispatch' => 0,
        'Log::Dispatch::Config::TestLog' => 0,
        'MooseX:Types::Set::Object' => 0,
        'Tie::RefHash' => 0,
	},
);

