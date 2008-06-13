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

    my $supervisor;

    POE::Session->create(
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
                                        sleep 1;
                                        exit 1;
                                    } else {
                                        sleep;
                                    }
                                },
                                stdout_callback => sub { my ( $key, $value ) = split /\s/, $_[ARG0]; push @{ $pids{$key} ||= [] }, $value },
                            ),
                        } ( 1 .. 5 ),
                    ],
                );

                $_[KERNEL]->delay_set( stop_children => 1.5 );
            },
            stop_children => sub {
                $supervisor->stop;
            },
            
        },
    );

    $poe_kernel->run;

    is( scalar(keys %pids), 5, "5 children" );

    # the numbers of PIDs we expect to have vary based on the policy
    my $before = ( $policy eq 'all' ? 2 : 1 );
    my $after  = ( $policy eq 'one' ? 1 : 2 );

    is( scalar(@{ $pids{1} }), $before, "child 1 had $before" );
    is( scalar(@{ $pids{2} }), $before, "child 2 had $before" );
    is( scalar(@{ $pids{3} }), 2,       "child 3 has 2" );
    is( scalar(@{ $pids{4} }), $after,  "child 4 had $after" );
    is( scalar(@{ $pids{5} }), $after,  "child 5 had $after" );
}

