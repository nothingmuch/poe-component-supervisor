#!/usr/bin/perl

use strict;
use warnings;

use Log::Dispatch::Config::TestLog;

use Test::More 'no_plan';

use ok 'POE::Component::Supervisor';
use ok 'POE::Component::Supervisor::Supervised::Proc';

use POE;

{
    # test a simple explicit stop scenario

    my $output = 0;
    my $pid;

    my ( $supervisor, $child );

    POE::Session->create(
        inline_states => {
            _start => sub {
                $supervisor = POE::Component::Supervisor->new(
                    children => [
                        $child = POE::Component::Supervisor::Supervised::Proc->new(
                            until_kill => 5,
                            program => sub {

                                foreach my $sig ( values %SIG ) {
                                    $sig = 'IGNORE';
                                }

                                while (1) {
                                    print "$$\n";
                                    sleep 1;
                                }
                            },
                            stdout_callback => sub { $pid ||= 0 + $_[ARG0]; $output++ },
                        ),
                    ],
                );

                $_[KERNEL]->delay_set( stop_child => 2, $supervisor );
            },
            stop_child => sub {
                $supervisor->stop($child);
            },
        },
    );

    $poe_kernel->run;

    # until_kill + stop_child delay == 5 + 2 == 7
    cmp_ok( $output, '>=', 6, "output" );
    cmp_ok( $output, '<=', 8, "output" );

    isnt( $pid, $$, "pid was diff" );
}


