/*
     Copyright (c) Richard Smith 2011

    This file is part of hxzmq.
	
    0MQ is free software; you can redistribute it and/or modify it under
    the terms of the Lesser GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    0MQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    Lesser GNU General Public License for more details.

    You should have received a copy of the Lesser GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <assert.h>
#include <zmq.h>
#include <hx/CFFI.h>

// Define a Kind type name for ZMQ context handles, which are opaque to the Haxe layer
DEFINE_KIND(k_zmq_context_handle);

// Finalizer for context
void finalize_context( value v) {
	gc_enter_blocking();
	int ret = zmq_term( val_data(v));
	gc_exit_blocking();
	if (ret != 0) {
		int err = zmq_errno();
		val_throw(alloc_int(err));
	}
}

value hx_zmq_construct (value io_threads)
{
	if (!val_is_int(io_threads))
		return alloc_null();
		
	int _io_threads = val_int(io_threads);
	if (_io_threads <= 0) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	void *c = zmq_init (_io_threads);
	int err = zmq_errno();
	
	if (c == NULL) {
		val_throw (alloc_int(err));
		return alloc_null();
	}
	
	// See: http://nekovm.org/doc/ffi#abstracts_and_kinds
	value v =  alloc_abstract(k_zmq_context_handle,c);
	val_gc(v,finalize_context);		// finalize_context is called when the abstract value is garbage collected
	return v;
	
}

value hx_zmq_term(value v)
{
	// Ensure v represents a previously created ZMQ context handle
	val_check_kind(v,k_zmq_context_handle);
	// Remove automatic gc finaliser calback
	val_gc(v,0);
	// Terminate the context
	finalize_context(v);
	return alloc_null();
}

DEFINE_PRIM( hx_zmq_construct, 1);
DEFINE_PRIM( hx_zmq_term, 1);