package Slim::Networking::Async::Socket;

# $Id$

# SqueezeCenter Copyright (c) 2003-2006 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License, 
# version 2.

# A base class for all sockets

use strict;
use warnings;

# store data within the socket
sub set {
	my ( $self, $key, $val ) = @_;
	
	${*$self}{$key} = $val;
}

# pull data out of the socket
sub get {
	my ( $self, $key ) = @_;
	
	return ${*$self}{$key};
}

1;