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

package org.zeromq.guide;
import haxe.io.Bytes;
import neko.Lib;
import neko.Sys;

import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

/**
 * Hello World client in Haxe.
 */
class HelloWorldClient 
{
	
	public static function main() {
		var context:ZMQContext = ZMQContext.instance();
		var socket:ZMQSocket = context.socket(ZMQ_REQ);
		
		Lib.println("** HelloWorldClient (see: http://zguide.zeromq.org/page:all#Ask-and-Ye-Shall-Receive)");
		
		trace ("Connecting to hello world server...");
		socket.connect ("tcp://localhost:5556");
		
		// Do 10 requests, waiting each time for a response
		for (i in 0...10) {
			var requestString = "Hello ";
			
			// Send the message
			trace ("Sending request " + i + " ...");
			socket.sendMsg(Bytes.ofString(requestString));
			
			// Wait for the reply
			var msg:Bytes = socket.recvMsg();
			
			trace ("Received reply " + i + ": [" + msg.toString() + "]");
			
		}
		
		// Shut down socket and context
		socket.close();
		context.term();
	}
}