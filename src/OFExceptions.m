/*
 * Copyright (c) 2008 - 2009
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#include "config.h"

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#import <objc/objc-api.h>
#ifdef __objc_INCLUDE_GNU
#define SEL_NAME(x) sel_get_name(x)
#else
#import <objc/runtime.h>
#define SEL_NAME(x) sel_getName(x)
#endif

#import "OFExceptions.h"
#import "OFTCPSocket.h"

#ifndef _WIN32
#include <errno.h>
#define GET_ERR	     errno
#ifndef HAVE_GETADDRINFO
#define GET_AT_ERR   h_errno
#else
#define GET_AT_ERR   errno
#endif
#define GET_SOCK_ERR errno
#define ERRFMT	     "Error string was: %s"
#define ERRPARAM     strerror(err)
#ifndef HAVE_GETADDRINFO
#define AT_ERRPARAM  hstrerror(err)
#else
#define AT_ERRPARAM  strerror(err)
#endif
#else
#include <windows.h>
#define GET_ERR	     GetLastError()
#define GET_AT_ERR   WSAGetLastError()
#define GET_SOCK_ERR WSAGetLastError()
#define ERRFMT	     "Error code was: %d"
#define ERRPARAM     err
#define AT_ERRPARAM  err
#endif

#import "asprintf.h"

@implementation OFAllocFailedException
+ (Class)class
{
	return self;
}

- (OFString*)string
{
	return @"Allocating an object failed!";
}
@end

@implementation OFException
+ newWithClass: (Class)class__
{
	return [[self alloc] initWithClass: class__];
}

- init
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
{
	self = [super init];

	class_ = class__;

	return self;
}

- (void)dealloc
{
	[string release];

	[super dealloc];
}

- (Class)inClass
{
	return class_;
}

- (OFString*)string
{
	return string;
}
@end

@implementation OFOutOfMemoryException
+ newWithClass: (Class)class__
	  size: (size_t)size
{
	return [[self alloc] initWithClass: class__
				      size: size];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	   size: (size_t)size
{
	self = [super initWithClass: class__];

	req_size = size;

	return self;
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Could not allocate %zu bytes in class %s!", req_size,
	    [class_ className]];

	return string;
}

- (size_t)requestedSize
{
	return req_size;
}
@end

@implementation OFMemoryNotPartOfObjectException
+ newWithClass: (Class)class__
       pointer: (void*)ptr
{
	return [[self alloc] initWithClass: class__
				   pointer: ptr];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	pointer: (void*)ptr
{
	self = [super initWithClass: class__];

	pointer = ptr;

	return self;
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Memory at %p was not allocated as part of object of class %s, "
	    @"thus the memory allocation was not changed! It is also possible "
	    @"that there was an attempt to free the same memory twice.",
	    pointer, [class_ className]];

	return string;
}

- (void*)pointer
{
	return pointer;
}
@end

@implementation OFNotImplementedException
+ newWithClass: (Class)class__
      selector: (SEL)selector_
{
	return [[self alloc] initWithClass: class__
				  selector: selector_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
       selector: (SEL)selector_
{
	self = [super initWithClass: class__];

	selector = selector_;

	return self;
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The method %s of class %s is not or not fully implemented!",
	    SEL_NAME(selector), [class_ className]];

	return string;
}
@end

@implementation OFOutOfRangeException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Value out of range in class %s!", [class_ className]];

	return string;
}
@end

@implementation OFInvalidArgumentException
+ newWithClass: (Class)class__
      selector: (SEL)selector_
{
	return [[self alloc] initWithClass: class__
				  selector: selector_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
       selector: (SEL)selector_
{
	self = [super initWithClass: class__];

	selector = selector_;

	return self;
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The argument for method %s of class %s is invalid!",
	    SEL_NAME(selector), [class_ className]];

	return string;
}
@end

@implementation OFInvalidEncodingException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The encoding is invalid for class %s!", [class_ className]];

	return string;
}
@end

@implementation OFInvalidFormatException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The format is invalid for class %s!", [class_ className]];

	return string;
}
@end

@implementation OFMalformedXMLException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The parser in class %s encountered malformed or invalid XML!",
	    [class_ className]];

	return string;
}
@end

@implementation OFInitializationFailedException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Initialization failed for class %s!", [class_ className]];

	return string;
}
@end

@implementation OFOpenFileFailedException
+ newWithClass: (Class)class__
	  path: (OFString*)path_
	  mode: (OFString*)mode_
{
	return [[self alloc] initWithClass: class__
				      path: path_
				      mode: mode_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	   path: (OFString*)path_
	   mode: (OFString*)mode_
{
	self = [super initWithClass: class__];

	path = [path_ copy];
	mode = [mode_ copy];
	err  = GET_ERR;

	return self;
}

- (void)dealloc
{
	[path release];
	[mode release];

	[super dealloc];
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Failed to open file %s with mode %s in class %s! " ERRFMT,
	    [path cString], [mode cString], [class_ className], ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}

- (OFString*)path
{
	return path;
}

- (OFString*)mode
{
	return mode;
}
@end

@implementation OFReadOrWriteFailedException
+ newWithClass: (Class)class__
	  size: (size_t)size
	 items: (size_t)items
{
	return [[self alloc] initWithClass: class__
				      size: size
				     items: items];
}

+ newWithClass: (Class)class__
	  size: (size_t)size
{
	return [[self alloc] initWithClass: class__
				      size: size];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	   size: (size_t)size
	  items: (size_t)items
{
	self = [super initWithClass: class__];

	req_size = size;
	req_items = items;
	has_items = YES;

	if (class__ == [OFTCPSocket class])
		err = GET_SOCK_ERR;
	else
		err = GET_ERR;

	return self;
}

- initWithClass: (Class)class__
	   size: (size_t)size
{
	self = [super initWithClass: class__];

	req_size = size;
	req_items = 0;
	has_items = NO;

	if (class__ == [OFTCPSocket class])
		err = GET_SOCK_ERR;
	else
		err = GET_ERR;

	return self;
}

- (int)errNo
{
	return err;
}

- (size_t)requestedSize
{
	return req_size;
}

- (size_t)requestedItems
{
	return req_items;
}

- (BOOL)hasNItems
{
	return has_items;
}
@end

@implementation OFReadFailedException
- (OFString*)string
{
	if (string != nil)
		return string;;

	if (has_items)
		string = [[OFString alloc] initWithFormat:
		    @"Failed to read %zu items of size %zu in class %s! "
		    ERRFMT, req_items, req_size, [class_ className], ERRPARAM];
	else
		string = [[OFString alloc] initWithFormat:
		    @"Failed to read %zu bytes in class %s! " ERRFMT, req_size,
		    [class_ className], ERRPARAM];

	return string;
}
@end

@implementation OFWriteFailedException
- (OFString*)string
{
	if (string != nil)
		return string;

	if (has_items)
		string = [[OFString alloc] initWithFormat:
		    @"Failed to write %zu items of size %zu in class %s! "
		    ERRFMT, req_items, req_size, [class_ className], ERRPARAM];
	else
		string = [[OFString alloc] initWithFormat:
		    @"Failed to write %zu bytes in class %s! " ERRFMT, req_size,
		    [class_ className], ERRPARAM];

	return string;
}
@end

@implementation OFLinkFailedException
+ newWithClass: (Class)class__
	source: (OFString*)src_
   destination: (OFString*)dest_
{
	return [[self alloc] initWithClass: class__
				    source: src_
			       destination: dest_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	 source: (OFString*)src_
    destination: (OFString*)dest_
{
	self = [super initWithClass: class__];

	src  = [src_ copy];
	dest = [dest_ copy];
	err  = GET_ERR;

	return self;
}

- (void)dealloc
{
	[src release];
	[dest release];

	[super dealloc];
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Failed to link file %s to %s in class %s! " ERRFMT,
	    [src cString], [dest cString], [class_ className], ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}

- (OFString*)source
{
	return src;
}

- (OFString*)destination
{
	return dest;
}
@end

@implementation OFSymlinkFailedException
+ newWithClass: (Class)class__
	source: (OFString*)src_
   destination: (OFString*)dest_
{
	return [[self alloc] initWithClass: class__
				    source: src_
			       destination: dest_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	 source: (OFString*)src_
    destination: (OFString*)dest_
{
	self = [super initWithClass: class__];

	src  = [src_ copy];
	dest = [dest_ copy];
	err  = GET_ERR;

	return self;
}

- (void)dealloc
{
	[src release];
	[dest release];

	[super dealloc];
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Failed to symlink file %s to %s in class %s! " ERRFMT,
	    [src cString], [dest cString], [class_ className], ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}

- (OFString*)source
{
	return src;
}

- (OFString*)destination
{
	return dest;
}
@end

@implementation OFSetOptionFailedException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Setting an option in class %s failed!", [class_ className]];

	return string;
}
@end

@implementation OFNotConnectedException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The socket of type %s is not connected or bound!",
	    [class_ className]];

	return string;
}
@end

@implementation OFAlreadyConnectedException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The socket of type %s is already connected or bound and thus "
	    @"can't be connected or bound again!", [class_ className]];

	return string;
}
@end

@implementation OFAddressTranslationFailedException
+ newWithClass: (Class)class__
	  node: (OFString*)node_
       service: (OFString*)service_
{
	return [[self alloc] initWithClass: class__
				      node: node_
				   service: service_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	   node: (OFString*)node_
	service: (OFString*)service_
{
	self = [super initWithClass: class__];

	node	= [node_ copy];
	service = [service_ copy];
	err	= GET_AT_ERR;

	return self;
}

- (void)dealloc
{
	[node release];
	[service release];

	[super dealloc];
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"The service %s on %s could not be translated to an address in "
	    @"class %s. This means that either the node was not found, there "
	    @"is no such service on the node, there was a problem with the "
	    @"name server, there was a problem with your network connection "
	    @"or you specified an invalid node or service. " ERRFMT,
	    [service cString], [node cString], [class_ className], AT_ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}

- (OFString*)node
{
	return node;
}

- (OFString*)service
{
	return service;
}
@end

@implementation OFConnectionFailedException
+ newWithClass: (Class)class__
	  node: (OFString*)node_
       service: (OFString*)service_
{
	return [[self alloc] initWithClass: class__
				      node: node_
				   service: service_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	   node: (OFString*)node_
	service: (OFString*)service_
{
	self = [super initWithClass: class__];

	node	= [node_ copy];
	service	= [service_ copy];
	err	= GET_SOCK_ERR;

	return self;
}

- (void)dealloc
{
	[node release];
	[service release];

	[super dealloc];
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"A connection to service %s on node %s could not be established "
	    @"in class %s! " ERRFMT, [node cString], [service cString],
	    [class_ className], ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}

- (OFString*)node
{
	return node;
}

- (OFString*)service
{
	return service;
}
@end

@implementation OFBindFailedException
+ newWithClass: (Class)class__
	  node: (OFString*)node_
       service: (OFString*)service_
	family: (int)family_
{
	return [[self alloc] initWithClass: class__
				      node: node_
				   service: service_
				    family: family_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	   node: (OFString*)node_
	service: (OFString*)service_
	 family: (int)family_
{
	self = [super initWithClass: class__];

	node	= [node_ copy];
	service	= [service_ copy];
	family	= family_;
	err	= GET_SOCK_ERR;

	return self;
}

- (void)dealloc
{
	[node release];
	[service release];

	[super dealloc];
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Binding service %s on node %s using family %d failed in class "
	    @"%s! " ERRFMT, [service cString], [node cString], family,
	    [class_ className], ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}

- (OFString*)node
{
	return node;
}

- (OFString*)service
{
	return service;
}

- (int)family
{
	return family;
}
@end

@implementation OFListenFailedException
+ newWithClass: (Class)class__
       backLog: (int)backlog_
{
	return [[self alloc] initWithClass: class__
				   backLog: backlog_];
}

- initWithClass: (Class)class__
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- initWithClass: (Class)class__
	backLog: (int)backlog_
{
	self = [super initWithClass: class__];

	backlog = backlog_;
	err = GET_SOCK_ERR;

	return self;
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Failed to listen in socket of type %s with a back log of %d! "
	    ERRFMT, [class_ className], backlog, ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}

- (int)backLog
{
	return backlog;
}
@end

@implementation OFAcceptFailedException
- initWithClass: (Class)class__
{
	self = [super initWithClass: class__];

	err = GET_SOCK_ERR;

	return self;
}

- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Failed to accept connection in socket of type %s! " ERRFMT,
	    [class_ className], ERRPARAM];

	return string;
}

- (int)errNo
{
	return err;
}
@end

@implementation OFThreadJoinFailedException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"Joining a thread of class %s failed! Most likely, another thread "
	    @"already waits for the thread to join.", [class_ className]];

	return string;
}
@end

@implementation OFMutexLockFailedException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"A mutex could not be locked in class %s", [class_ className]];

	return string;
}
@end

@implementation OFMutexUnlockFailedException
- (OFString*)string
{
	if (string != nil)
		return string;

	string = [[OFString alloc] initWithFormat:
	    @"A mutex could not be unlocked in class %s", [class_ className]];

	return string;
}
@end
