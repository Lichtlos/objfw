/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016
 *   Jonathan Schleifer <js@heap.zone>
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

#import "OFException.h"

/*!
 * @class OFMoveItemFailedException \
 *	  OFMoveItemFailedException.h ObjFW/OFMoveItemFailedException.h
 *
 * @brief An exception indicating that moving an item failed.
 */
@interface OFMoveItemFailedException: OFException
{
	OFString *_sourcePath, *_destinationPath;
	int _errNo;
}

/*!
 * The original path.
 */
@property (readonly, copy) OFString *sourcePath;

/*!
 * The new path.
 */
@property (readonly, copy) OFString *destinationPath;

/*!
 * The errno of the error that occurred.
 */
@property (readonly) int errNo;

/*!
 * @brief Creates a new, autoreleased move item failed exception.
 *
 * @param sourcePath The original path
 * @param destinationPath The new path
 * @param errNo The errno of the error that occurred
 * @return A new, autoreleased move item failed exception
 */
+ (instancetype)exceptionWithSourcePath: (OFString*)sourcePath
			destinationPath: (OFString*)destinationPath
				  errNo: (int)errNo;

/*!
 * @brief Initializes an already allocated move item failed exception.
 *
 * @param sourcePath The original path
 * @param destinationPath The new path
 * @param errNo The errno of the error that occurred
 * @return An initialized move item failed exception
 */
- initWithSourcePath: (OFString*)sourcePath
     destinationPath: (OFString*)destinationPath
	       errNo: (int)errNo;
@end
