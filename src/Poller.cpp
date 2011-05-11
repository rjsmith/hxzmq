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

value hx_zmq_poll (value sockets_, value events_, value timeout_) {

	if (!val_is_int(timeout_) || !val_is_array(sockets_) || !val_is_array(events_)) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	//value *sockets_array;
	//value *events_array;
	//sockets_array = val_array_ptr( sockets_ );
	//events_array = val_array_ptr ( events_ );
	
	int ls = val_array_size(sockets_);
	int le = val_array_size(events_);
	
	if (ls != le) {
		val_throw(alloc_int(EINVAL));
		return alloc_null();
	}
	
	zmq_pollitem_t *pitem = new zmq_pollitem_t [ls];
	for (int i = 0; i < ls; i++) {
		value socket = val_array_i(sockets_, i);
		value event = val_array_i(events_, i);
		
		// Test that array index values are of the expected value type
		val_check_kind(socket, k_zmq_socket_handle);
		if (!val_is_int(event)) {
			val_throw(alloc_int(EINVAL));
			delete [] pitem;
			return alloc_null();
		}
		
		pitem [i].socket = val_data (socket);
		pitem [i].fd = 0;
		pitem [i].events = val_int (event);
		pitem [i].revents = 0;	
	}
	
	gc_enter_blocking();
	
	int rc = 0;
	int err = 0;
	long tout = val_int(timeout_);

	rc = zmq_poll (pitem, ls, tout);
    err = zmq_errno();
	
	gc_exit_blocking();
	
	if (rc == -1) {
		val_throw(alloc_int(err));
		delete [] pitem;
		return alloc_null();
	}		
	
	// return results 
	value retObj = alloc_empty_object ();
	alloc_field( retObj, val_id("_ret"), alloc_int(rc));
	// build returned _revents int array
	value haxe_revents = alloc_array(ls);
	for (int i = 0; i < ls; i++) {
		val_array_set_i (haxe_revents, i, alloc_int(pitem[i].revents));
	}
	alloc_field( retObj, val_id("_revents"), haxe_revents);
	
	delete [] pitem;
	pitem = NULL;

	return retObj;
		
}

DEFINE_PRIM (hx_zmq_poll, 3);