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

#import "OFMacros.h"

#if !defined(OF_THREADS)
# define of_atomic_add32(p, i) (*p += i)
# define of_atomic_sub32(p, i) (*p -= i)
# define of_atomic_or32(p, i) (*p |= i)
# define of_atomic_and32(p, i) (*p &= i)
# define of_atomic_xor32(p, i) (*p ^= i)

static OF_INLINE BOOL
of_atomic_cmpswap32(int32_t *p, int32_t o, int32_t n)
{
	if (*p == o) {
		*p = n;
		return YES;
	}

	return NO;
}
#elif defined(OF_HAVE_GCC_ATOMIC_OPS)
# define of_atomic_add32(p, i) __sync_add_and_fetch(p, i)
# define of_atomic_sub32(p, i) __sync_sub_and_fetch(p, i)
# define of_atomic_or32(p, i) __sync_or_and_fetch(p, i)
# define of_atomic_and32(p, i) __sync_and_and_fetch(p, i)
# define of_atomic_xor32(p, i) __sync_xor_and_fetch(p, i)
# define of_atomic_cmpswap32(p, o, n) __sync_bool_compare_and_swap(p, o, n)
#elif defined(OF_HAVE_LIBKERN_OSATOMIC_H)
# include <libkern/OSAtomic.h>
# define of_atomic_add32(p, i) OSAtomicAdd32Barrier(i, p)
# define of_atomic_sub32(p, i) OSAtomicAdd32Barriar(-(i), p)
# define of_atomic_inc32(p) OSAtomicIncrement32Barrier(p)
# define of_atomic_dec32(p) OSAtomicDecrement32Barrier(p)
# define of_atomic_or32(p, i) OSAtomicOr32Barrier(i, p)
# define of_atomic_and32(p, i) OSAtomicAnd32Barrier(i, p)
# define of_atomic_xor32(p, i) OSAtomicXor32Barrier(i, p)
# define of_atomic_cmpswap32(p, o, n) OSAtomicCompareAndSwap32Barrier(o, n, p)
#else
# error No atomic operations available!
#endif

#if !defined(OF_THREADS) || defined(OF_HAVE_GCC_ATOMIC_OPS)
# define of_atomic_inc32(p) of_atomic_add32(p, 1)
# define of_atomic_dec32(p) of_atomic_sub32(p, 1)
#endif
