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

#include <stdlib.h>
#include <string.h>
#include <math.h>

#import "OFDoubleMatrix.h"
#import "OFDoubleVector.h"
#import "OFString.h"

#import "OFInvalidArgumentException.h"
#import "OFNotImplementedException.h"
#import "OFOutOfMemoryException.h"
#import "OFOutOfRangeException.h"

#import "macros.h"

static Class doubleVector = Nil;

@implementation OFDoubleMatrix
+ (void)initialize
{
	if (self == [OFDoubleMatrix class])
		doubleVector = [OFDoubleVector class];
}

+ matrixWithRows: (size_t)rows
	 columns: (size_t)columns
{
	return [[[self alloc] initWithRows: rows
				   columns: columns] autorelease];
}

+ matrixWithRows: (size_t)rows
  columnsAndData: (size_t)columns, ...
{
	id ret;
	va_list arguments;

	va_start(arguments, columns);
	ret = [[[self alloc] initWithRows: rows
				  columns: columns
				arguments: arguments] autorelease];
	va_end(arguments);

	return ret;
}

- init
{
	Class c = isa;
	[self release];
	@throw [OFNotImplementedException newWithClass: c
					      selector: _cmd];
}

- initWithRows: (size_t)rows_
       columns: (size_t)columns_
{
	self = [super init];

	@try {
		rows = rows_;
		columns = columns_;

		if (SIZE_MAX / rows < columns ||
		    SIZE_MAX / rows * columns < sizeof(double))
			@throw [OFOutOfRangeException
			    newWithClass: isa];

		if ((data = malloc(rows * columns * sizeof(double))) == NULL)
			@throw [OFOutOfMemoryException
			     newWithClass: isa
			    requestedSize: rows * columns * sizeof(double)];

		memset(data, 0, rows * columns * sizeof(double));

		if (rows == columns) {
			size_t i;

			for (i = 0; i < rows * columns; i += rows + 1)
				data[i] = 1;
		}
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

-   initWithRows: (size_t)rows_
  columnsAndData: (size_t)columns_, ...
{
	id ret;
	va_list arguments;

	va_start(arguments, columns_);
	ret = [self initWithRows: rows_
			 columns: columns_
		       arguments: arguments];
	va_end(arguments);

	return ret;
}

- initWithRows: (size_t)rows_
       columns: (size_t)columns_
     arguments: (va_list)arguments
{
	self = [super init];

	@try {
		size_t i;

		rows = rows_;
		columns = columns_;

		if (SIZE_MAX / rows < columns ||
		    SIZE_MAX / rows * columns < sizeof(double))
			@throw [OFOutOfRangeException newWithClass: isa];

		if ((data = malloc(rows * columns * sizeof(double))) == NULL)
			@throw [OFOutOfMemoryException
			     newWithClass: isa
			    requestedSize: rows * columns * sizeof(double)];

		for (i = 0; i < rows; i++) {
			size_t j;

			for (j = i; j < rows * columns; j += rows)
				data[j] = (double)va_arg(arguments, double);
		}
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	free(data);

	[super dealloc];
}

- (void)setValue: (double)value
	  forRow: (size_t)row
	  column: (size_t)column
{
	if (row >= rows || column >= columns)
		@throw [OFOutOfRangeException newWithClass: isa];

	data[row * columns + column] = value;
}

- (double)valueForRow: (size_t)row
	      column: (size_t)column
{
	if (row >= rows || column >= columns)
		@throw [OFOutOfRangeException newWithClass: isa];

	return data[row * columns + column];
}

- (size_t)rows
{
	return rows;
}

- (size_t)columns
{
	return columns;
}

- (BOOL)isEqual: (id)object
{
	OFDoubleMatrix *otherMatrix;

	if (![object isKindOfClass: [OFDoubleMatrix class]])
		return NO;

	otherMatrix = object;

	if (otherMatrix->rows != rows || otherMatrix->columns != columns)
		return NO;

	if (memcmp(otherMatrix->data, data, rows * columns * sizeof(double)))
		return NO;

	return YES;
}

- (uint32_t)hash
{
	size_t i;
	uint32_t hash;

	OF_HASH_INIT(hash);

	for (i = 0; i < rows * columns; i++) {
		union {
			double f;
			uint64_t i;
		} u;

		u.f = data[i];

		OF_HASH_ADD_INT64(hash, u.i);
	}

	OF_HASH_FINALIZE(hash);

	return hash;
}

- copy
{
	OFDoubleMatrix *copy = [[isa alloc] initWithRows: rows
						columns: columns];

	memcpy(copy->data, data, rows * columns * sizeof(double));

	return copy;
}

- (OFString*)description
{
	OFMutableString *description;
	size_t i;

	description = [OFMutableString stringWithFormat: @"<%@, (\n",
							 [self className]];

	for (i = 0; i < rows; i++) {
		size_t j;

		[description appendString: @"\t"];

		for (j = 0; j < columns; j++) {

			if (j != columns - 1)
				[description
				    appendFormat: @"%10f ",
						  data[j * rows + i]];
			else
				[description
				    appendFormat: @"%10f\n",
						  data[j * rows + i]];
		}
	}

	[description appendString: @")>"];

	/*
	 * Class swizzle the string to be immutable. We declared the return type
	 * to be OFString*, so it can't be modified anyway. But not swizzling it
	 * would create a real copy each time -[copy] is called.
	 */
	description->isa = [OFString class];
	return description;
}

- (double*)cArray
{
	return data;
}

- (void)addMatrix: (OFDoubleMatrix*)matrix
{
	size_t i;

	if (matrix->isa != isa || matrix->rows != rows ||
	    matrix->columns != columns)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	for (i = 0; i < rows * columns; i++)
		data[i] += matrix->data[i];
}

- (void)subtractMatrix: (OFDoubleMatrix*)matrix
{
	size_t i;

	if (matrix->isa != isa || matrix->rows != rows ||
	    matrix->columns != columns)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	for (i = 0; i < rows * columns; i++)
		data[i] -= matrix->data[i];
}


- (void)multiplyWithScalar: (double)scalar
{
	size_t i;

	for (i = 0; i < rows * columns; i++)
		data[i] *= scalar;
}

- (void)divideByScalar: (double)scalar
{
	size_t i;

	for (i = 0; i < rows * columns; i++)
		data[i] /= scalar;
}

- (void)multiplyWithMatrix: (OFDoubleMatrix*)matrix
{
	double *newData;
	size_t i, base1, base2;

	if (rows != matrix->columns)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	if ((newData = malloc(matrix->rows * columns * sizeof(double))) == NULL)
		@throw [OFOutOfMemoryException
		     newWithClass: isa
		    requestedSize: matrix->rows * columns * sizeof(double)];

	base1 = 0;
	base2 = 0;

	for (i = 0; i < columns; i++) {
		size_t base3 = base2;
		size_t j;

		for (j = 0; j < matrix->rows; j++) {
			size_t base4 = j;
			size_t base5 = base1;
			double tmp = 0.0;
			size_t k;

			for (k = 0; k < matrix->columns; k++) {
				tmp += matrix->data[base4] * data[base5];
				base4 += matrix->rows;
				base5++;
			}

			newData[base3] = tmp;
			base3++;
		}

		base1 += rows;
		base2 += matrix->rows;
	}

	free(data);
	data = newData;

	rows = matrix->rows;
}

- (void)transpose
{
	double *newData;
	size_t i, k;

	if ((newData = malloc(rows * columns * sizeof(double))) == NULL)
		@throw [OFOutOfMemoryException newWithClass: isa
					      requestedSize: rows * columns *
							     sizeof(double)];

	rows ^= columns;
	columns ^= rows;
	rows ^= columns;

	for (i = k = 0; i < rows; i++) {
		size_t j;

		for (j = i; j < rows * columns; j += rows)
			newData[j] = data[k++];
	}

	free(data);
	data = newData;
}

- (void)translateWithVector: (OFDoubleVector*)vector
{
	OFDoubleMatrix *translation;
	double *cArray;

	if (rows != columns || vector->isa != doubleVector ||
	    vector->dimension != rows - 1)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	cArray = [vector cArray];
	translation = [[OFDoubleMatrix alloc] initWithRows: rows
						  columns: columns];

	memcpy(translation->data + (columns - 1) * rows, cArray,
	    (rows - 1) * sizeof(double));

	@try {
		[self multiplyWithMatrix: translation];
	} @finally {
		[translation release];
	}
}

- (void)rotateWithVector: (OFDoubleVector*)vector
		   angle: (double)angle
{
	OFDoubleMatrix *rotation;
	double n[3], m, angleCos, angleSin;

	if (rows != 4 || columns != 4 || vector->isa != doubleVector ||
	    vector->dimension != 3)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	n[0] = vector->data[0];
	n[1] = vector->data[1];
	n[2] = vector->data[2];

	m = sqrt(n[0] * n[0] + n[1] * n[1] + n[2] * n[2]);

	if (m != 1.0) {
		n[0] /= m;
		n[1] /= m;
		n[2] /= m;
	}

	angle = (double)(angle * M_PI / 180.0);
	angleCos = cos(angle);
	angleSin = sin(angle);

	rotation = [[OFDoubleMatrix alloc] initWithRows: rows
					       columns: columns];

	rotation->data[0] = angleCos + n[0] * n[0] * (1 - angleCos);
	rotation->data[1] = n[1] * n[0] * (1 - angleCos) + n[2] * angleSin;
	rotation->data[2] = n[2] * n[0] * (1 - angleCos) - n[1] * angleSin;

	rotation->data[4] = n[0] * n[1] * (1 - angleCos) - n[2] * angleSin;
	rotation->data[5] = angleCos + n[1] * n[1] * (1 - angleCos);
	rotation->data[6] = n[2] * n[1] * (1 - angleCos) + n[0] * angleSin;

	rotation->data[8] = n[0] * n[2] * (1 - angleCos) + n[1] * angleSin;
	rotation->data[9] = n[1] * n[2] * (1 - angleCos) - n[0] * angleSin;
	rotation->data[10] = angleCos + n[2] * n[2] * (1 - angleCos);

	@try {
		[self multiplyWithMatrix: rotation];
	} @finally {
		[rotation release];
	}
}

- (void)scaleWithVector: (OFDoubleVector*)vector
{
	OFDoubleMatrix *scale;
	double *cArray;
	size_t i, j;

	if (rows != columns || vector->isa != doubleVector ||
	    vector->dimension != rows - 1)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	cArray = [vector cArray];
	scale = [[OFDoubleMatrix alloc] initWithRows: rows
					    columns: columns];

	for (i = j = 0; i < ((rows - 1) * columns) - 1; i += rows + 1)
		scale->data[i] = cArray[j++];

	@try {
		[self multiplyWithMatrix: scale];
	} @finally {
		[scale release];
	}
}
@end