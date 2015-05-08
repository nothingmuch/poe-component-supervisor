package POE::Component::Supervisor::Supervised::Interface;
use Moose::Role;

use namespace::clean -except => 'meta';

requires qw(
    spawn
);

__PACKAGE__

__END__
