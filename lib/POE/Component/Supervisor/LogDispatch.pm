package POE::Component::Supervisor::LogDispatch;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(MooseX::LogDispatch);

# borked due to role impl... =P
# has '+use_logger_singleton' => ( default => 1 );

has 'use_logger_singleton' => (
    is => "rw",
    isa => "Bool",
    default => 1
);

__PACKAGE__

__END__

=pod

=head1 NAME

POE::Component::Supervisor::LogDispatch - Logging role

=head1 SYNOPSIS

    with qw(POE::Component::Supervisor::LogDispatch);

=head1 DESCRIPTION

This is a variation on L<MooseX::LogDispatch> that ensures that a global
L<Log::Dispatch::Config> singleton will be respected.

=cut


