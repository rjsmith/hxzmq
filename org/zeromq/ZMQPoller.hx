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
		
		// Split pollItems array into 2 separate arrays to pass to the native layer
		var sArray:Array<Dynamic> = new Array<Dynamic>();
		var eArray:Array<Int> = new Array<Int>();
		
		revents = null;		// Clear out revents array ready for next set of results
		revents = new Array<Int>();
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
	
	private static var _hx_zmq_poll = Lib.load("hxzmq", "hx_zmq_poll", 3);
}

typedef PollSocketEventTuple = {
	_socket:ZMQSocket,
	_event:Int };
	
typedef PollResult = {
	_revents:Array<Int>,
	_ret:Int
};