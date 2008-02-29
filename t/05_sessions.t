#!/usr/bin/perl

use strict;
use warnings;

use Log::Dispatch::Config::TestLog;

use Test::More 'no_plan';

use POE::Component::Supervisor;
use POE::Component::Supervisor::Supervised::Session;

use POE;

{
    # normal exit scenario

    my @pids;

    my ( $supervisor, $child );

    my ( $started, $blah, $stopped );

    POE::Session->create(
        inline_states => {
            _start => sub {
                $supervisor = POE::Component::Supervisor->new(
                    children => [
                        $child = POE::Component::Supervisor::Supervised::Session->new(
                            start_callback => sub {
                                POE::Session->create(
                                    inline_states => {
                                        _start => sub {
                                            $started++;
                                            $_[KERNEL]->yield("blah");
                                        },
                                        blah => sub {
                                            $blah++;
                                        },
                                        _stop => sub {
                                            $stopped++;
                                        },
                                    },
                                );
                            },
                        ),
                    ],
                );
            },
        },
    );

    $poe_kernel->run;

    is( $started, 1, "subsession started" );
    is( $blah, 1, "blah event delivered" );
    is( $stopped, 1, "child session stopped normally" );
}

{
    # abnormal exit scenario

    my @pids;

    my ( $supervisor, $child );

    my ( $started, $blah, $stopped, $died );

    POE::Session->create(
        inline_states => {
            _start => sub {
                $supervisor = POE::Component::Supervisor->new(
                    children => [
                        $child = POE::Component::Supervisor::Supervised::Session->new(
                            start_callback => sub {
                                POE::Session->create(
                                    inline_states => {
                                        _start => sub {
                                            $started++;
                                            $_[KERNEL]->yield("blah");
                                        },
                                        blah => sub {
                                            if ( not $blah++ ) {
                                                $died++;
                                                die "blah"; # only dies the first time
                                            }
                                        },
                                        _stop => sub {
                                            $stopped++;
                                        },
                                    },
                                );
                            },
                        ),
                    ],
                );
            },
        },
    );

    $poe_kernel->run;

    is( $started, 2, "subsession started" );
    is( $blah, 2, "blah event delivered" );
    is( $died, 1, "died once" );
    is( $stopped, 2, "child session stopped" );
}

{
    # implicit tracking

    my @pids;

    my ( $supervisor, $child );

    my ( $started, $blah, $died, %died, $stopped );

    POE::Session->create(
        inline_states => {
            _start => sub {
                $supervisor = POE::Component::Supervisor->new(
                    children => [
                        $child = POE::Component::Supervisor::Supervised::Session->new(
                            implicit_tracking => 1,
                            start_callback => sub {
                                foreach my $id ( 1 .. 2 ) {
                                    POE::Session->create(
                                        inline_states => {
                                            _start => sub {
                                                $started++;
                                                $_[KERNEL]->yield("blah");
                                            },
                                            blah => sub {
                                                $blah++;
                                                if ( not $died{$id}++ ) {
                                                    $died++;
                                                    die "blah"; # only dies the first time
                                                }
                                            },
                                            _stop => sub {
                                                $stopped++;
                                            },
                                        },
                                    );
                                }

                                return;
                            },
                        ),
                    ],
                );
            },
        },
    );

    $poe_kernel->run;

    is( $started, 4, "subsessions started" );
    is( $blah, 4, "blah events delivered" );
    is( $died, 2, "deaths" );
    is( $stopped, 4, "child sessions stopped" );
}

