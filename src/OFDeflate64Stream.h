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

#import "OFDeflateStream.h"

OF_ASSUME_NONNULL_BEGIN

/*!
 * @class OFDeflate64Stream OFDeflate64Stream.h ObjFW/OFDeflate64Stream.h
 *
 * @brief A class that handles Deflate64 decompression transparently for an
 *	  underlying stream.
 */
@interface OFDeflate64Stream: OFDeflateStream
@end

OF_ASSUME_NONNULL_END
