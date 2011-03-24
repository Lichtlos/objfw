/*
 * Copyright (c) 2008, 2009, 2010, 2011
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

#import "OFBindFailedException.h"
#import "OFString.h"

#import "OFNotImplementedException.h"

#import "common.h"

@implementation OFBindFailedException
+ newWithClass: (Class)class_
	  host: (OFString*)host
	  port: (uint16_t)port
{
	return [[self alloc] initWithClass: class_
				      host: host
				      port: port];
}

- initWithClass: (Class)class_
{
	Class c = isa;
	[self release];
	@throw [OFNotImplementedException newWithClass: c
					      selector: _cmd];
}

- initWithClass: (Class)class_
	   host: (OFString*)host_
	   port: (uint16_t)port_
{
	self = [super initWithClass: class_];

	@try {
		host  = [host_ copy];
		port  = port_;
		errNo = GET_SOCK_ERRNO;
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[host release];

	[super dealloc];
}

- (OFString*)description
{
	if (description != nil)
		return description;

	description = [[OFString alloc] initWithFormat:
	    @"Binding to port %" @PRIu16 @" on host %@ failed in class %@! "
	    ERRFMT, port, host, inClass, ERRPARAM];

	return description;
}

- (int)errNo
{
	return errNo;
}

- (OFString*)host
{
	return host;
}

- (uint16_t)port
{
	return port;
}
@end