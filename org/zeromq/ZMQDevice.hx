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
 * Creates in-built ZMQ devices that run in the current thread of execution.
 * 
 * DEPRECATED in 3.1.x branch
 */

class ZMQDevice 
{
	public function new() {
		throw new ZMQException(ENOTSUP);
	}

}