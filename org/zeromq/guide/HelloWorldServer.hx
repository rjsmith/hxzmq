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
import org.zeromq.ZMQException;
import org.zeromq.ZMQSocket;

/**
 * Hello World server in Haxe
 * Binds REP to tcp://*:5556
 * Expects "Hello" from client, replies with "World"
 * 
 */
class HelloWorldServer 
{

	public static function main() {
		
		var context:ZMQContext = ZMQContext.instance();
		var responder:ZMQSocket = context.socket(ZMQ_REP);

		Lib.println("** HelloWorldServer (see: http://zguide.zeromq.org/page:all#Ask-and-Ye-Shall-Receive)");

		responder.setsockopt(ZMQ_LINGER, 0);
		responder.bind("tcp://*:5556");
		
		try {
			while (true) {
				// Wait for next request from client
				var request:Bytes = responder.recvMsg();
				
				trace ("Received request:" + request.toString());
				
				// Do some work
				Sys.sleep(1);
				
				// Send reply back to client
				responder.sendMsg(Bytes.ofString("World"));
			}
		} catch (e:ZMQException) {
			trace (e.toString());
		}
		responder.close();
		context.term();
		
	}
	
}