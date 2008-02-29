#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'POE::Component::Supervisor::Supervised';
use ok 'POE::Component::Supervisor::Handle';
use ok 'POE::Component::Supervisor';

use ok 'POE::Component::Supervisor::Handle::Proc';
use ok 'POE::Component::Supervisor::Supervised::Proc';
