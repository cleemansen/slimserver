package Slim::Networking::Async::Socket::HTTPS;

# $Id$

# SqueezeCenter Copyright (c) 2003-2006 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License, 
# version 2.

use strict;
use warnings;

BEGIN {
	# Force Net::HTTPS to use IO::Socket::SSL
	use IO::Socket::SSL;
}

use base qw(Net::HTTPS Slim::Networking::Async::Socket);

sub close {
	my $self = shift;

	# remove self from select loop
	Slim::Networking::Select::removeError($self);
	Slim::Networking::Select::removeRead($self);
	Slim::Networking::Select::removeWrite($self);
	Slim::Networking::Select::removeWriteNoBlockQ($self);

	$self->SUPER::close();
}

1;