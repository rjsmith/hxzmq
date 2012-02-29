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
#include <cstring>
#include <zmq.h>
#include <hx/CFFI.h>


#include "socket.h"

value hx_zmq_device (value type_, value frontend_, value backend_) {
	
	if (!val_is_int(type_) ) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	val_check_kind(frontend_, k_zmq_socket_handle);
	val_check_kind(backend_, k_zmq_socket_handle);
	
#if ZMQ_VERSION >= ZMQ_MAKE_VERSION(3,0,0)	
    int rc = -1;
	int err = ENOTSUP;
#else
	int rc = zmq_device(val_int(type_), val_data(frontend_), val_data(backend_));
	int err = zmq_errno();
#endif

	if (rc != 0) {
		val_throw(alloc_int(err));
		return alloc_null();
	}
	return alloc_int(rc);
}
DEFINE_PRIM( hx_zmq_device, 3);
