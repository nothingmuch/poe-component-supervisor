#!/usr/bin/perl

package POE::Component::Supervisor::Handle;
use Moose::Role;

has child => (
    isa => "POE::Component::Supervisor::Supervised",
    is  => "ro",
    required => 1,
);

has supervisor => (
    isa => "POE::Component::Supervisor",
    is  => "rw",
    is_weak  => 1,
    required => 1,
);

has spawned => (
    isa => "Bool",
    is  => "rw",
    writer => "_spawned",
);

has stopped => (
    isa => "Bool",
    is  => "rw",
    writer => "_stopped",
);

has [map { "${_}_callback" } qw(spawned stopped)] => (
    isa => "CodeRef",
    is  => "rw",
    required => 0,
);

requires "stop";

requires "is_running";

sub stop_for_restart { shift->stop(@_) }

sub notify_supervisor {
    my ( $self, $event, @args ) = @_;

    $self->supervisor->yield( $event => $self->child, @args );
}

sub notify_spawn {
    my ( $self, @args ) = @_;

    $self->_spawned(1);

    $self->notify_supervisor( spawned => @args );

    if ( my $cb = $self->spawned_callback ) {
        $self->$cb(@args);
    }
}

sub notify_stop {
    my ( $self, @args ) = @_;

    $self->_stopped(1);

    $self->notify_supervisor( stopped => @args );

    if ( my $cb = $self->stopped_callback ) {
        $self->$cb(@args);
    }
}

__PACKAGE__

__END__

=pod

=head1 NAME

POE::Component::Supervisor::Handle - Base role for supervision handles

=head1 SYNOPSIS
    
    # see Handle::Proc and Handle::Session

=head1 DESCRIPTION

This is a base role for supervision handles.

=head1 ATTRIBUTES

=over 4

=item supervisor

The L<POE::Component::Supervisor> utilizing over this handle.

=item child

The child descriptor this handle was spawned for.

=item spawned_callback

=item stopped_callback

These callbacks are called as handle methods with the arguments sent to the
supervisor.

Note that they are not invoked with L<POE>'s calling convention, but rather
arbitrary arguments from the supervision handle.

=back

=head1 METHODS

=over 4

=item stop

Stops the running supervised thingy.

Required.

=item is_running

Checks if the supervised thingy is running.

Required.

=item stop_for_restart

By default an alias to C<stop>.

If stopping for the purpose of a restart should be handled differently this can
be overridden.

=back

=cut


