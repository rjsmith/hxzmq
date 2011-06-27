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

import org.zeromq.ZMQ;

/**
 * Encapsulates ZMQ Errors
 * Provides the ZMQ - specified errno and a human - readable description
 */
class ZMQException {
	
	public var err(default, null):ErrorType;
	
	public var errNo(default,null):Int;
	
    // Allows error string to be overriden on creation (e.g. for preserving php-zmq errors)
    private var overriddenStr:String;
    
	public function new(e:ErrorType, ?str:String ) {
		this.err = e;
		this.errNo = ZMQ.errorTypeToErrNo(err);
        if (str != null) this.overriddenStr = str;
	}
	
	/**
	 * Returns ZMQ - specified human-readable error description
	 * @return
	 */
	public function str():String {
		return { if (overriddenStr != null) overriddenStr else ZMQ.strError(errNo); };
	}
	
	public function toString():String {
		var b:StringBuf = new StringBuf();
		
		b.add("errNo:" + errNo + ", str:" + str());
		
		return b.toString();
	}
	
}