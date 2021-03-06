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

#import "OFObject.h"
#import "OFStream.h"

OF_ASSUME_NONNULL_BEGIN

@class OFDate;

/*!
 * @brief The type of the archive entry.
 */
typedef enum of_tar_archive_entry_type_t {
	/*! Normal file */
	OF_TAR_ARCHIVE_ENTRY_TYPE_FILE		   = '0',
	/*! Hard link */
	OF_TAR_ARCHIVE_ENTRY_TYPE_LINK		   = '1',
	/*! Symbolic link */
	OF_TAR_ARCHIVE_ENTRY_TYPE_SYMLINK	   = '2',
	/*! Character device */
	OF_TAR_ARCHIVE_ENTRY_TYPE_CHARACTER_DEVICE = '3',
	/*! Block device */
	OF_TAR_ARCHIVE_ENTRY_TYPE_BLOCK_DEVICE	   = '4',
	/*! Directory */
	OF_TAR_ARCHIVE_ENTRY_TYPE_DIRECTORY	   = '5',
	/*! FIFO */
	OF_TAR_ARCHIVE_ENTRY_TYPE_FIFO		   = '6',
	/*! Contiguous file */
	OF_TAR_ARCHIVE_ENTRY_TYPE_CONTIGUOUS_FILE  = '7',
} of_tar_archive_entry_type_t;

/*!
 * @class OFTarArchiveEntry OFTarArchiveEntry.h ObjFW/OFTarArchiveEntry.h
 *
 * @brief A class which represents an entry of a tar archive.
 */
@interface OFTarArchiveEntry: OFStream
{
	OFStream *_stream;
	bool _atEndOfStream;
	OFString *_fileName;
	uint32_t _mode;
	uint64_t _size, _toRead;
	OFDate *_modificationDate;
	of_tar_archive_entry_type_t _type;
	OFString *_targetFileName;
	OFString *_owner, *_group;
	uint32_t _deviceMajor, _deviceMinor;
}

/*!
 * The file name of the entry.
 */
@property (readonly, copy) OFString *fileName;

/*!
 * The mode of the entry.
 */
@property (readonly) uint32_t mode;

/*!
 * The size of the file.
 */
@property (readonly) uint64_t size;

/*!
 * The date of the last modification of the file.
 */
@property (readonly, copy) OFDate *modificationDate;

/*!
 * The type of the archive entry.
 *
 * See @ref of_tar_archive_entry_type_t.
 */
@property (readonly) of_tar_archive_entry_type_t type;

/*!
 * The file name of the target (for a hard link or symbolic link).
 */
@property (readonly, copy) OFString *targetFileName;

/*!
 * The owner of the file.
 */
@property (readonly, copy) OFString *owner;

/*!
 * The group of the file.
 */
@property (readonly, copy) OFString *group;

/*!
 * The device major (if the file is a device).
 */
@property (readonly) uint32_t deviceMajor;

/*!
 * The device major (if the file is a device).
 */
@property (readonly) uint32_t deviceMinor;
@end

OF_ASSUME_NONNULL_END
