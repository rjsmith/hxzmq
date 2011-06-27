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
#if php
import php.NativeArray;
#end
import org.zeromq.ZMQ;
import org.zeromq.ZMQSocket;

/**
 * Encapsulates ZMQ Poller functions.
 * 
 * Statefull class, maintaining a set of sockets to poll, events to poll for
 */
class ZMQPoller 
{
    /**
     * Provides the last-polled set of rececived events
     */
	public var revents(default,null):Array<Int>;

	private var pollItems:List<PollSocketEventTuple>;
		
	/**
	 * Constructor
	 */
	public function new() {
		
		pollItems = new List<PollSocketEventTuple>();
		revents = new Array<Int>();
		
	}
	
	public function getSize():Int {
		return pollItems.length;
	}
	
	/**
	 * Adds a socket to the internak list of polled sockets
	 * @param	socket	A ZMQScxket object
	 * @param	event	Bitmasked Int for polled events (ZMQ_POLLIN, ZMQ_POLLOUT)
	 */
	public function registerSocket(socket:ZMQSocket, event:Int)
	{
		
		if (socket == null || event == null) {
			throw new ZMQException(EINVAL);
			return;
		}
		
		pollItems.add( { _socket:socket, _event:event } );
					
	}
	
	/**
	 * Removes a previously registered socket
	 * @param	socket
	 * @return
	 */
	public function unregisterSocket(socket:ZMQSocket):Bool {
		
		if (socket == null) {
			throw new ZMQException(EINVAL);
			return null;
		}
		
		// Find first matching socket object, then remove it
		for (pi in pollItems) {
			if (pi._socket == socket) {
				pollItems.remove(pi);
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Removes all current registered sockets
	 */
	public function unregisterAllSockets() {
		pollItems.clear();
	}
	
	/**
	 * Poll a set of 0MQ sockets, 
	 * @param	?timeout	Timeout in microseconds, or 0 to return immediately, or -1 to block indefintely (default)
	 * @return	how many objects signalled, or 0 if none, or -1 if failure
	 */
	public function poll(?timeout:Int = -1):Int 
	{
		revents = null;		// Clear out revents array ready for next set of results
		revents = new Array<Int>();
#if (neko || cpp)
		// Split pollItems array into 2 separate arrays to pass to the native layer
		var sArray:Array<Dynamic> = new Array<Dynamic>();   // ZMQ Sockets
		var eArray:Array<Int> = new Array<Int>();           // Polled Event Types

		for (p in pollItems) {
			sArray.push(p._socket._socketHandle);
			eArray.push(p._event);
			revents.push(0);		// initialise revents array
		}
		
		try {			
			var r:PollResult = _hx_zmq_poll(sArray, eArray, timeout);
			if (r == null) {
				return -1;
			}
			revents = Lib.nekoToHaxe(r._revents).copy();
			return r._ret;
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
			return -1;
		} catch (e:Dynamic) {
			return -1;
		}
#elseif php
        var ZMQPollHandle:Dynamic = untyped __php__('new ZMQPoll()');      
        for (p in pollItems) {
            var s = p._socket._socketHandle;
            var e = p._event;
            untyped __php__('$ZMQPollHandle->add($s, $e)');
        }
        var _readableNativeArr:NativeArray = untyped __php__('array()');
        var _writableNativeArr:NativeArray = untyped __php__('array()');
        
        var r = untyped __php__('$ZMQPollHandle->poll($_readableNativeArr, $_writableNativeArr, $timeout)');
        var errs:NativeArray = untyped __php__('$ZMQPollHandle-> getLastErrors()');
        var errsArr = Lib.toHaxeArray(errs);
        if (errsArr.length > 0) {
            return -1;
        }
        // Convert native Array to haXe arrays
        var _readableArr:Array<Dynamic> = Lib.toHaxeArray(_readableNativeArr);
        var _writableArr:Array<Dynamic> = Lib.toHaxeArray(_writableNativeArr);
        // Iterate over registered sockets to build up revents array
        var item = 0;
        var numEvents = 0;
        for (p in pollItems) {
            revents[item] = 0;
            // Is this socket in the readableArr returned from the php poll?
            for (ra in _readableArr) {
                if (ra == p._socket._socketHandle) {
                    revents[item] |= ZMQ.ZMQ_POLLIN();
                    break;
                }
            }
            // Is this socket in the writableArr returned from the php poll?
            for (ra in _writableArr) {
                if (ra == p._socket._socketHandle) {
                    revents[item] |= ZMQ.ZMQ_POLLOUT();
                    break;
                }
            }
            if (revents[item] != 0) numEvents++;
            item++;
        }
        return numEvents;

#end
	}
	
	/**
	 * Test if the s'th registered socket has a registered POLLIN event.
	 * Call this after a poll() method call to test the results.
	 * 
	 * @param	s	Valid s parameter range from 1 to revents.length
	 * @return		True if specified registered socket has a current POLLIN event, else False
	 */
	public function pollin(s: Int):Bool {
		if (revents == null || revents.length == 0) return false;
		if (s > revents.length) return false;	
	
		return (revents[s - 1] & ZMQ.ZMQ_POLLIN()) == ZMQ.ZMQ_POLLIN();
	}
	
	/**
	 * Test if the s'th registered socket has a registered POLLOUT event.
	 * Call this after a poll() method call to test the results.
	 * 
	 * @param	s	Valid s parameter range from 1 to revents.length
	 * @return		True if specified registered socket has a current POLLOUT event, else False
	 */
	public function pollout(s: Int):Bool {
		if (revents == null || revents.length == 0) return false;
		if (s > revents.length) return false;	
	
		return (revents[s - 1] & ZMQ.ZMQ_POLLOUT()) == ZMQ.ZMQ_POLLOUT();
	}
	
	/**
	 * Test of the s'th registered socket has no received polled events
	 * @param	s	Valid s parameter range from 1 to revents.length
	 * @return		True if no received polled events on the socket
	 */
	public function noevents(s:Int):Bool {
		return (!pollin(s) && !pollout(s));
	}
	
#if (neko || cpp)    
	private static var _hx_zmq_poll = Lib.load("hxzmq", "hx_zmq_poll", 3);
#end
}

typedef PollSocketEventTuple = {
	_socket:ZMQSocket,
	_event:Int };
	
typedef PollResult = {
	_revents:Array<Int>,
	_ret:Int
};