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

#import "OFStream.h"

OF_ASSUME_NONNULL_BEGIN

/*!
 * @class OFStdIOStream OFStdIOStream.h ObjFW/OFStdIOStream.h
 *
 * @brief A class for providing standard input, output and error as OFStream.
 *
 * The global variables @ref of_stdin, @ref of_stdout and @ref of_stderr are
 * instances of this class and need no initialization.
 */
#ifdef OF_STDIO_STREAM_WIN32_CONSOLE_H
OF_SUBCLASSING_RESTRICTED
#endif
@interface OFStdIOStream: OFStream
{
	int  _fd;
	bool _atEndOfStream;
}

/*!
 * @brief Query the underlying terminal for the number of columns.
 *
 * @return The number of columns, or -1 if there is no underlying terminal or
 *	   the number of columns could not be queried
 */
- (int)columns;

/*!
 * @brief Query the underlying terminal for the number of rows.
 *
 * @return The number of rows, or -1 if there is no underlying terminal or the
 *	   number of rows could not be queried
 */
- (int)rows;
@end

#ifdef __cplusplus
extern "C" {
#endif
/*! @file */

/*!
 * @brief The standard input as an OFStream.
 */
extern OFStdIOStream *_Nullable of_stdin;

/*!
 * @brief The standard output as an OFStream.
 */
extern OFStdIOStream *_Nullable of_stdout;

/*!
 * @brief The standard error as an OFStream.
 */
extern OFStdIOStream *_Nullable of_stderr;

extern void of_log(OFConstantString*, ...);
#ifdef __cplusplus
}
#endif

OF_ASSUME_NONNULL_END
