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

import neko.Lib;
import haxe.io.Bytes;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;

/**
 * Hello World Client
 * Connects REQ socket to tcp://localhost:5559
 * Sends "Hello" to server, expects "World" back
 * 
 * See: http://zguide.zeromq.org/page:all#A-Request-Reply-Broker
 * 
 * Use with RrServer and RrBroker
 */
class RrClient 
{

    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
        
		Lib.println("** RrClient (see: http://zguide.zeromq.org/page:all#A-Request-Reply-Broker)");

		var requester:ZMQSocket = context.socket(ZMQ_REQ);
		requester.connect ("tcp://localhost:5559");
		
        Lib.println ("Launch and connect client.");
        
		// Do 10 requests, waiting each time for a response
		for (i in 0...10) {
			var requestString = "Hello ";
			// Send the message
			requester.sendMsg(Bytes.ofString(requestString));
			
			// Wait for the reply
			var msg:Bytes = requester.recvMsg();
			
			Lib.println("Received reply " + i + ": [" + msg.toString() + "]");
			
		}
		
		// Shut down socket and context
		requester.close();
		context.term();
    }
}