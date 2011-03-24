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

#import "OFObject.h"

@class OFString;

/**
 * \brief The base class for all exceptions in ObjFW
 *
 * The OFException class is the base class for all exceptions in ObjFW, except
 * the OFAllocFailedException.
 *
 * IMPORTANT: Exceptions do NOT use OFAutoreleasePools and can't be autoreleased
 * either! You have to make sure to dealloc the exception in your \@catch block!
 */
@interface OFException: OFObject
{
	Class inClass;
	OFString *description;
}

#ifdef OF_HAVE_PROPERTIES
@property (readonly, nonatomic) Class inClass;
#endif

/**
 * Creates a new exception.
 *
 * \param class_ The class of the object which caused the exception
 * \return A new exception
 */
+ newWithClass: (Class)class_;

/**
 * Initializes an already allocated OFException.
 *
 * \param class_ The class of the object which caused the exception
 * \return An initialized OFException
 */
- initWithClass: (Class)class_;

/**
 * \return The class of the object in which the exception happened
 */
- (Class)inClass;

/**
 * \return A description of the exception
 */
- (OFString*)description;
@end