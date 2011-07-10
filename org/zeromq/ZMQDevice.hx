/**
 * (c) 2011 Richard J Smith
 *
 * This file is part of hxzmq
 *
 * hxzmq is free software; you can redistribute it and/or modify it under
 * the terms of the Lesser GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * hxzmq is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Lesser GNU General Public License for more details.
 *
 * You should have received a copy of the Lesser GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.zeromq;

import neko.Lib;
import neko.Sys;
import org.zeromq.ZMQ;

/**
 * Wraps ZMQ zmq_device method call.
 * Creates in-built ZMQ devices that run in the current thread of execution
 */
class ZMQDevice 
{

	/**
	 * Constructor.
	 * Creates a new ZMQ device and immediately starts its in-built loop.
	 * Will continue unless process is interrupted, when it returns a ETERM ZMQ_Exception.
	 * @param	type		A valid DeviceType
	 * @param   frontend	Front end socket, bound or connected to by clients
	 * @param   backend     Back end socket, bound or connected to workers
	 */
	public function new(type:DeviceType, frontend:ZMQSocket, backend:ZMQSocket) 
	{
		if (frontend == null || frontend.closed) {
			throw new ZMQException(EINVAL);
		}
		if (backend == null || backend.closed) {
			throw new ZMQException(EINVAL);
		}
		if (type == null) {
			throw new ZMQException(EINVAL);
		}
#if (neko || cpp)		
		try {
			// This will continue to execute until current thread or process is terminated
			var rc = _hx_zmq_device(ZMQ.deviceTypeToDevice(type), frontend._socketHandle, backend._socketHandle);
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} catch (e:Dynamic) {
			Lib.rethrow(e);
		}
#elseif php
		var _typenum = ZMQ.deviceTypeToDevice(type);
		var _frontend_handle = frontend._socketHandle;
		var _backend_handle = backend._socketHandle;
		var r = untyped __php__('new ZMQDevice($_typenum, $_frontend_handle, $_backend_handle)'); 
#end

	}

#if (neko || cpp) 
	private static var _hx_zmq_device = Lib.load("hxzmq", "hx_zmq_device", 3);

#end
}