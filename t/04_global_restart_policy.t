#!/usr/bin/perl

sub POE::Kernel::USE_SIGCHLD () { 1 }

use strict;
use warnings;

use Log::Dispatch::Config::TestLog;

use Test::More 'no_plan';

use ok 'POE::Component::Supervisor';
use ok 'POE::Component::Supervisor::Supervised::Proc';

use POE;

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
                            POE::Component::Supervisor::Supervised::Proc->new(
                                program => sub {
                                    print "$i $$\n";
                                    if ( $i == 3 ) {
                                        exit 1;
                                    } else {
                                        sleep;
                                    }
                                },
                                stdout_callback => sub {
                                    my ( $key, $value ) = split /\s/, $_[ARG0];
                                    push @{ $pids{$key} ||= [] }, $value;

                                    if ( @{ $pids{$key} } > 2 ) {
                                        $supervisor->stop;
                                        $poe_kernel->post( $session, "clear_alarm" );
                                    }
                                },
                            ),
                        } ( 1 .. 5 ),
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

    is( scalar(keys %pids), 5, "5 children" );

    # the numbers of PIDs we expect to have vary based on the policy
    my @before = ( $policy eq 'all' ? ( '>=', 2 ) : ( '==', 1 ));
    my @after  = ( $policy eq 'one' ? ( '==', 1 ) : ( '>=', 2 ) );

    cmp_ok( scalar(@{ $pids{1} }), $before[0], $before[1], "child 1 had $before[1]" );
    cmp_ok( scalar(@{ $pids{2} }), $before[0], $before[1], "child 2 had $before[1]" );
    cmp_ok( scalar(@{ $pids{3} }), '>=',      2,           "child 3 has 2" );
    cmp_ok( scalar(@{ $pids{4} }), $after[0], $after[1],   "child 4 had $after[1]" );
    cmp_ok( scalar(@{ $pids{5} }), $after[0], $after[1],   "child 5 had $after[1]" );
}

