#!/usr/bin/perl

package POE::Component::Supervisor::Interface;
use Moose::Role;

use namespace::clean -except => 'meta';

requires qw(
    notify_spawned
    notify_stopped
);

__PACKAGE__

__END__

=pod

=head1 NAME

POE::Component::Supervisor::Interface - Minimal interface for supervisors

=head1 SYNOPSIS

    package My::Supervisor;
    with qw(POE::Component::Supervisor::Interface);

    

=head1 DESCRIPTION

This role lets you implement your own supervisor, reusing
L<POE::Component::Supervisor::Supervised> and
L<POE::Component::Supervisor::Handle> implementations.

This is useful if you'd like to start/stop/monitor child components/processes
without the monitoring/restarting logic in L<POE::Component::Supervisor>
itself.

=head1 REQUIRED METHODS



=cut


