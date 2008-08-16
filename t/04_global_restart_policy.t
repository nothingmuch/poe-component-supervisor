#!/usr/bin/perl

sub POE::Kernel::USE_SIGCHLD () { 1 }

use strict;
use warnings;

use Log::Dispatch::Config::TestLog;

use Test::More 'no_plan';

use ok 'POE::Component::Supervisor';
use ok 'POE::Component::Supervisor::Supervised::Proc';
use ok 'POE::Component::Supervisor::Supervised::Session';

use POE;

my @classes = qw(Proc Session);
foreach my $class ( @classes, undef, undef ) {
    foreach my $policy qw(one all rest) {
        my %pids;

        my ( $supervisor, $session );

        $session = POE::Session->create(
            inline_states => {
                _start => sub {
                    $supervisor = POE::Component::Supervisor->new(
                        restart_policy => $policy,
                        children => [
                            map {
                                my $i = $_;
                                my $actual_class = ( $class || $classes[int rand @classes] );

                                if ( $actual_class eq 'Proc' ) {
                                    POE::Component::Supervisor::Supervised::Proc->new(
                                        program => sub {
                                            $| = 1;
                                            print "$i proc=$$\n";
                                            if ( $i == 5 ) {
                                                exit 1;
                                            } else {
                                                sleep 10; # not indefinitely, hangs in some cases
                                            }
                                        },
                                        stdout_callback => sub {
                                            my ( $key, $value ) = split /\s/, $_[ARG0];
                                            push @{ $pids{$key} ||= [] }, $value;

                                            if ( @{ $pids{$key} } >= 3 ) {
                                                $supervisor->stop;
                                                $poe_kernel->post( $session, "clear_alarm" );
                                            }
                                        },
                                    );
                                } else {
                                    POE::Component::Supervisor::Supervised::Session->new(
                                        start_callback => sub {
                                            POE::Session->create(
                                                inline_states => {
                                                    _start => sub {
                                                        $poe_kernel->yield("body");
                                                        push @{ $pids{$i} ||= [] }, "session=" . $_[SESSION]->ID;

                                                        if ( @{ $pids{$i} } >= 3 ) {
                                                            $supervisor->stop;
                                                            $poe_kernel->post( $session, "clear_alarm" );
                                                        }

                                                        POE::Session->create(
                                                            inline_states => {
                                                                _start => sub { $_[KERNEL]->yield("elk") },
                                                            },
                                                        );
                                                    },
                                                    body => sub {
                                                        if ( $i == 5 ) {
                                                            die "OI";
                                                        } else {
                                                            $_[KERNEL]->delay_set( blah => 10 );
                                                        }
                                                    },
                                                }
                                            );
                                        },
                                    );
                                }
                            } ( 1 .. 10 ),
                        ],
                    );

                    $_[KERNEL]->delay_set( stop_children => 5 );
                },
                clear_alarm => sub {
                    $_[KERNEL]->alarm_remove_all;
                },
                stop_children => sub {
                    $supervisor->stop;
                },
                
            },
        );

        $poe_kernel->run;

        is( scalar(keys %pids), 10, "10 children ($policy, " . ($class  || "random") . ")" );

        # the numbers of PIDs we expect to have vary based on the policy
        my @before = ( $policy eq 'all' ? ( '>=', 2 ) : ( '==', 1 ));
        my @after  = ( $policy eq 'one' ? ( '==', 1 ) : ( '>=', 2 ) );

        cmp_ok( scalar(@{ $pids{1} }), $before[0], $before[1], "child 1 had $before[1]" );
        cmp_ok( scalar(@{ $pids{2} }), $before[0], $before[1], "child 2 had $before[1]" );
        cmp_ok( scalar(@{ $pids{3} }), $before[0], $before[1], "child 3 had $before[1]" );
        cmp_ok( scalar(@{ $pids{3} }), $before[0], $before[1], "child 4 had $before[1]" );
        cmp_ok( scalar(@{ $pids{5} }), '>=',      2,           "child 5 has 2" );
        cmp_ok( scalar(@{ $pids{6} }), $after[0], $after[1],   "child 6 had $after[1]" );
        cmp_ok( scalar(@{ $pids{7} }), $after[0], $after[1],   "child 7 had $after[1]" );
        cmp_ok( scalar(@{ $pids{8} }), $after[0], $after[1],   "child 8 had $after[1]" );
        cmp_ok( scalar(@{ $pids{9} }), $after[0], $after[1],   "child 9 had $after[1]" );
    }
}

