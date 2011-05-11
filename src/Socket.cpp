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

#ifdef _MSC_VER
// Add stdint.hpp header file from zeromq distro to pick up integer types definitions
// Required by hxcpp build tool on windows if using msvc build tool?
#include <stdint.hpp>
#endif

#include <assert.h>
#include <cstring>
#include <zmq.h>
#include <hx/CFFI.h>

#include "socket.h"

DEFINE_KIND( k_zmq_socket_handle );

DECLARE_KIND( k_zmq_context_handle );

// Finalizer for context
void finalize_socket( value v) {
	gc_enter_blocking();
	int ret = zmq_close( val_data(v));
	gc_exit_blocking();
	if (ret != 0) {
		int err = zmq_errno();
		val_throw(alloc_int(err));
	}
}

value hx_zmq_construct_socket (value context_handle,value type)
{
	val_is_kind(context_handle,k_zmq_context_handle);
	if (!val_is_int(type)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
		
	void *s = zmq_socket (val_data(context_handle),val_int(type));
	int err = zmq_errno();
	
	if (s == NULL) {
		val_throw (alloc_int(err));
		return alloc_null();
	}
	
	// See: http://nekovm.org/doc/ffi#abstracts_and_kinds
	value v =  alloc_abstract(k_zmq_socket_handle,s);
	val_gc(v,finalize_socket);		// finalize_socket is called when the abstract value is garbage collected
	return v;
	
}

value hx_zmq_close(value socket_handle)
{
	// Ensure v represents a previously created ZMQ socket handle
	val_check_kind(socket_handle, k_zmq_socket_handle);
	
	// Remove the automatic gc finaliser callback
	val_gc(socket_handle, 0);
	
	// Close the socket
	finalize_socket(socket_handle);
	
	return alloc_null();
}

value hx_zmq_bind(value socket_handle, value addr)
{
	val_check_kind(socket_handle, k_zmq_socket_handle);
	if (!val_is_string(addr)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	int rc = zmq_bind(val_data(socket_handle),val_string(addr));
	int err = zmq_errno();
	
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_null();
	}
	return alloc_int(rc);
		
}

value hx_zmq_connect(value socket_handle, value addr)
{
	val_check_kind(socket_handle, k_zmq_socket_handle);
	if (!val_is_string(addr)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	int rc = zmq_connect(val_data(socket_handle),val_string(addr));
	int err = zmq_errno();
	
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_null();
	}
	
	return alloc_int(rc);
		
}

/*
See Socket.cpp from jzmq library
*/
value hx_zmq_setintsockopt(value socket_handle_,value option_, value optval_) {

	val_check_kind(socket_handle_, k_zmq_socket_handle);

	if (!val_is_int(option_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	if (!val_is_int(optval_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}

	int rc = 0;
	int err = 0;
	int ival = val_int(optval_);
	int option = val_int(option_);
	size_t optvallen = sizeof(ival);
	
	rc = zmq_setsockopt (val_data(socket_handle_), option, &ival, optvallen);
    err = zmq_errno();
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_null();
	}		
	return alloc_int(rc);
}


value hx_zmq_setint64sockopt(value socket_handle_,value option_, value hi_optval_, value lo_optval_) {

	val_check_kind(socket_handle_, k_zmq_socket_handle);

	if (!val_is_int(option_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	if (!val_is_int(hi_optval_) || !val_is_int(lo_optval_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	uint64_t _optval64 = val_int(hi_optval_);
	_optval64 <<= 32;	// Shift the hi int into the top half of the uint64_t value
	_optval64 += val_int(lo_optval_);
	
	int rc = 0;
	int err = 0;
	int option = val_int(option_);
	size_t optvallen = sizeof(_optval64);
	
	rc = zmq_setsockopt (val_data(socket_handle_), option, &_optval64, optvallen);
    err = zmq_errno();
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_null();
	}		
	return alloc_int(rc);
	
}

value hx_zmq_setbytessockopt(value socket_handle_, value option_, value bytes_optval_) {

	val_check_kind(socket_handle_, k_zmq_socket_handle);

	if (!val_is_int(option_)) {
		printf("option_ is not int");
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}

	size_t size = 0;
	uint8_t *data = 0;
	
	// If data from neko
	if (val_is_string(bytes_optval_))
	{
		size = val_strlen(bytes_optval_);
		data = (uint8_t *)val_string(bytes_optval_);		
	} // else from C++
	else if (val_is_buffer(bytes_optval_))
	{
		buffer buf = val_to_buffer(bytes_optval_);
		size = buffer_size(buf);
		data = (uint8_t *)buffer_data(buf);		
	} else {
		printf("bytes_optval_ not string or buffer");
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
		
	int rc = 0;
	int err = 0;
	int option = val_int(option_);

	rc = zmq_setsockopt (val_data(socket_handle_), option, data, size);
	
    err = zmq_errno();
	if (rc != 0) {
		printf("err:%d",err);
		val_throw(alloc_int(err));
		return alloc_null();
	}		
	return alloc_int(rc);
	
}

value hx_zmq_getintsockopt(value socket_handle_,value option_) {

	val_check_kind(socket_handle_, k_zmq_socket_handle);

	if (!val_is_int(option_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}

	int rc = 0;
	int err = 0;
	uint64_t optval = 0;
	size_t optvallen = sizeof(optval);
	rc = zmq_getsockopt(val_data(socket_handle_),val_int(option_),&optval, &optvallen);
	err = zmq_errno();
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_int(0);
	}		
	return alloc_int(optval);
}

value hx_zmq_getint64sockopt(value socket_handle_,value option_) {

	val_check_kind(socket_handle_, k_zmq_socket_handle);

	if (!val_is_int(option_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}

	int rc = 0;
	int err = 0;
	uint64_t optval = 0;
	size_t optvallen = sizeof(optval);
	rc = zmq_getsockopt(val_data(socket_handle_),val_int(option_),&optval, &optvallen);
	err = zmq_errno();
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_int(0);
	}	
	value ret = alloc_empty_object();
	alloc_field(ret, val_id("hi"),alloc_int(optval >> 32));
	alloc_field(ret, val_id("lo"),alloc_int(optval & 0xFFFFFFFF));
	
	return ret;
}

value hx_zmq_getbytessockopt(value socket_handle_,value option_) {

	val_check_kind(socket_handle_, k_zmq_socket_handle);

	if (!val_is_int(option_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}

	int rc = 0;
	int err = 0;
	char optval [255];
	size_t optvallen = 255;
	rc = zmq_getsockopt(val_data(socket_handle_),val_int(option_),&optval, &optvallen);
	err = zmq_errno();
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_int(0);
	}	
	
	// Return data to Haxe

	// Create a return buffer byte array, by memcopying the message data, then discard the ZMQ message
	buffer b = alloc_buffer(NULL);
	buffer_append_sub(b,optval,optvallen);
	err = zmq_errno();
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_null();
	}
	
	return buffer_val(b);
}


/**
 * Receive data from socket
 * Based on code in  https://github.com/zeromq/jzmq/blob/master/src/Socket.cpp
 */
value hx_zmq_send(value socket_handle_, value msg_data, value flags) {
	
	val_check_kind(socket_handle_, k_zmq_socket_handle);
	
	if (!val_is_null(flags) && !val_is_int(flags)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	size_t size = 0;
	uint8_t *data = 0;
	
	
	zmq_msg_t message;

	// Extract byte data from either Neko string or C++ buffer
	// see: http://waxe.googlecode.com/svn-history/r32/trunk/src/waxe/HaxeAPI.cpp "Val2ByteData"
	if (val_is_string(msg_data))
	{
		// Neko
		size = val_strlen(msg_data);
		data = (uint8_t *)val_string(msg_data);
	}
	else if (val_is_buffer(msg_data))
	{
		// CPP
		buffer buf = val_to_buffer(msg_data);
		size = buffer_size(buf);
		data = (uint8_t *)buffer_data(buf);
	} else {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
		
	
	// Set up send message buffer by referencing the provided bytes data
    //zero copy version: int rc = zmq_msg_init_data (&message, data, size,NULL,NULL);
	int rc = zmq_msg_init_size(&message, size);
	memcpy (zmq_msg_data(&message), data, size);
	
    int err = zmq_errno();
    if (rc != 0) {
        val_throw(alloc_int(err));
        return alloc_null();
    }

	gc_enter_blocking();
	// Send
    rc = zmq_send (val_data(socket_handle_), &message, val_int(flags));
    err = zmq_errno();
	
	gc_exit_blocking();
	
	// If NOBLOCK, but cant send message now, close message first before quitting
    if (rc != 0 && err == EAGAIN) {
        rc = zmq_msg_close (&message);
        err = zmq_errno();
        if (rc != 0) {
			val_throw(alloc_int(err));
			return alloc_null();
        }
        return alloc_null();
    }
    
    if (rc != 0) {
        val_throw(alloc_int(err));
        rc = zmq_msg_close (&message);
        err = zmq_errno();
        if (rc != 0) {
			val_throw(alloc_int(err));
			return alloc_null();
        }
        return alloc_null();
    }

    rc = zmq_msg_close (&message);
    err = zmq_errno();
    if (rc != 0) {
			val_throw(alloc_int(err));
			return alloc_null();
    }
	return alloc_null();
}

/**
 * Receive data from socket
 * Based on code in  https://github.com/zeromq/jzmq/blob/master/src/Socket.cpp
 */
value hx_zmq_rcv(value socket_handle_, value flags) {
	
	val_check_kind(socket_handle_, k_zmq_socket_handle);
	
	if (!val_is_null(flags) && !val_is_int(flags)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	zmq_msg_t message;

    int rc = zmq_msg_init (&message);
    int err = zmq_errno();
    if (rc != 0) {
        val_throw(alloc_int(err));
        return alloc_null();
    }
	
	gc_enter_blocking();

    rc = zmq_recv (val_data(socket_handle_), &message, val_int(flags));

	gc_exit_blocking();

    err = zmq_errno();
    if (rc != 0 && err == EAGAIN) {
        rc = zmq_msg_close (&message);
        err = zmq_errno();
        if (rc != 0) {
			val_throw(alloc_int(err));
			return alloc_null();
        }
        return alloc_null();
    }

    if (rc != 0) {
        rc = zmq_msg_close (&message);
        int err1 = zmq_errno();
        if (rc != 0) {
			val_throw(alloc_int(err1));
			return alloc_null();
        }
        val_throw(alloc_int(err));
        return alloc_null();
    }
	
	// Return data to Haxe
	int sz = zmq_msg_size (&message);
    const char* pd = (char *)zmq_msg_data (&message);

	// Create a return buffer byte array, by memcopying the message data, then discard the ZMQ message
	buffer b = alloc_buffer(NULL);
	buffer_append_sub(b,pd,sz);
	rc = zmq_msg_close (&message);
	err = zmq_errno();
	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_null();
	}
	return buffer_val(b);
}

DEFINE_PRIM( hx_zmq_construct_socket, 2);
DEFINE_PRIM( hx_zmq_close, 1);
DEFINE_PRIM( hx_zmq_bind, 2);
DEFINE_PRIM( hx_zmq_connect, 2);
DEFINE_PRIM( hx_zmq_send, 3);
DEFINE_PRIM( hx_zmq_rcv, 2);
DEFINE_PRIM( hx_zmq_setintsockopt,3);
DEFINE_PRIM( hx_zmq_setint64sockopt,4);
DEFINE_PRIM( hx_zmq_setbytessockopt,3);
DEFINE_PRIM( hx_zmq_getintsockopt,2);
DEFINE_PRIM( hx_zmq_getint64sockopt,2);
DEFINE_PRIM( hx_zmq_getbytessockopt,2);
