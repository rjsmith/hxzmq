/*
  Copyright (c) 2011 Richard J Smith

  This file is part of hxzmq.

  hxzmq is free software; you can redistribute it and/or modify it under
  the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.

  hxzmq is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.zeromq;

import neko.Lib;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

class ZMQContext  {

	/** Opaque data used by hxzmq driver */
 	public var contextHandle(default,null):Dynamic;
	
	/** Records if context has been terminated */
	public var closed(default,null):Bool;
	
	private static var _instance:ZMQContext;
	private static var _hasInstance:Bool;

	/**
	 * Creates a ZMQ Context
	 * 
	 * Can throw EINVAL if invalid number of iothreads requested
	 * 
	 * See: http://api.zeromq.org/master:zmq-init
	 */
	private function new(ioThreads:Int) {
		closed = true;
		
		// Initialize the zmq context
		try {
			contextHandle = _hx_zmq_construct(ioThreads);
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} catch (e:Dynamic) {
			trace(e);
		} 
		closed = false;
	}
	
	/**
	 * Close or terminate the context
	 * 
	 * This can be called to close the context by hand. If this is not
     * called, the context will automatically be closed when it is
     * garbage collected.
	 */
	public function term():Void {
		if (!closed) {
			try {
				_hx_zmq_term(contextHandle);
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			}
			
			closed = true;
			contextHandle = null;
			_hasInstance = false;
		}
	}
	
	/**
	 * Create a Socket associated with this Context
	 * @param	socketType	The socket type which can be any of the ZMQ socket types
	 * @return  A ZMQSocket object
	 */
	public function socket(type:SocketType):ZMQSocket {
		if (closed)
			throw new ZMQException(ENOTSUP);
		
		return new ZMQSocket(this, type);
	}
	
	/**
	 * Convenience method to create a ZMQPoller object.
	 * Raises a ENOTSUP ZMQException if context is closed
	 * @return	A ZMQPoller object
	 */
	public function poller():ZMQPoller {
		if (closed)
			throw new ZMQException(ENOTSUP);

		return new ZMQPoller();	
	}
	
	/**
	 * Returns a global ZMQContext instance, or null
	 * 
	 * @param	?ioThreads = 1
	 */
	public static function instance(?ioThreads = 1):ZMQContext {
		if (!_hasInstance) {
			_instance = new ZMQContext (ioThreads);
			_hasInstance = true;
		}
			
		return {
			if (_hasInstance) _instance else null;	
		}
	}

#if (cpp || neko)	
	private static var _hx_zmq_construct = neko.Lib.load("hxzmq", "hx_zmq_construct", 1);
	private static var _hx_zmq_term = neko.Lib.load("hxzmq", "hx_zmq_term", 1);
#elseif php
    private static function _hx_zmq_construct(ioThreads:Int):Dynamic {
        // Implement this test explicitly as php-zmq doesnt seem to detect / trap it.
        if (ioThreads == 0) {
            throw ZMQ.errorTypeToErrNo(EINVAL);
            return null;
        }
        return untyped __php__('new ZMQContext($ioThreads)');
    }
    
    private static function _hx_zmq_term(ctx:Dynamic):Void {
        // Explicity destroy the php ZMQContext object (which invokes zmq_term in the php-zmq binding)
        untyped __call__('unset', ctx);
    }
#end	
}