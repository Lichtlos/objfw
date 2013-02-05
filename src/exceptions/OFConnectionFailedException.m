/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#include <stdlib.h>

#import "OFConnectionFailedException.h"
#import "OFString.h"
#import "OFTCPSocket.h"

#import "common.h"

@implementation OFConnectionFailedException
+ (instancetype)exceptionWithClass: (Class)class_
			    socket: (OFTCPSocket*)socket
			      host: (OFString*)host
			      port: (uint16_t)port
{
	return [[[self alloc] initWithClass: class_
				     socket: socket
				       host: host
				       port: port] autorelease];
}

- initWithClass: (Class)class_
{
	@try {
		[self doesNotRecognizeSelector: _cmd];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	abort();
}

- initWithClass: (Class)class_
	 socket: (OFTCPSocket*)socket_
	   host: (OFString*)host_
	   port: (uint16_t)port_
{
	self = [super initWithClass: class_];

	@try {
		socket = [socket_ retain];
		host   = [host_ copy];
		port   = port_;
		errNo  = GET_SOCK_ERRNO;
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[socket release];
	[host release];

	[super dealloc];
}

- (OFString*)description
{
	if (description != nil)
		return description;

	description = [[OFString alloc] initWithFormat:
	    @"A connection to %@ on port %" @PRIu16 @" could not be "
	    @"established in class %@! " ERRFMT, host, port, inClass, ERRPARAM];

	return description;
}

- (OFTCPSocket*)socket
{
	OF_GETTER(socket, NO)
}

- (OFString*)host
{
	OF_GETTER(host, NO)
}

- (uint16_t)port
{
	return port;
}

- (int)errNo
{
	return errNo;
}
@end
