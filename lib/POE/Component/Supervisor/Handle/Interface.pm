package POE::Component::Supervisor::Handle::Interface;
use Moose::Role;

use namespace::clean -except => 'meta';

requires qw(
    stop
    stop_for_restart
    is_running
);

__PACKAGE__

__END__
