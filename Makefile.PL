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
        'POE' => "1.0002", # DIE in parents
        'POE::API::Peek' => '2.13',
        'MooseX::POE' => "0.07",
        'MooseX::LogDispatch' => 0,
        'Log::Dispatch::Config::TestLog' => 0,
        'Set::Object' => 0,
        'Hash::Util::FieldHash::Compat' => 0,
        'namespace::clean' => 0,
	},
);

