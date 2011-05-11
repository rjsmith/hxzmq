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
import haxe.Stack;
import neko.Lib;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

/**
 * Signal Handling
 * 
 * Call 
 */
class Interrupt 
{

	public static function main() {
		var context:ZMQContext = ZMQContext.instance();
		var receiver:ZMQSocket = context.socket(ZMQ_REP);
		receiver.bind("tcp://127.0.0.1:5559");
		
		Lib.println("** Interrupt (see: http://zguide.zeromq.org/page:all#Handling-Interrupt-Signals)");
		
		ZMQ.catchSignals();
		
		Lib.println ("\nPress Ctrl+C");

		while (true) {
			// Blocking read, will exit only on an interrupt (Ctrl+C)
			
			try {
			   var msg:Bytes = receiver.recvMsg();
			} catch (e:ZMQException) {
				if (ZMQ.isInterrupted()) {
					trace ("W: interrupt received, killing server ...\n");
					break;
				}
				
				// Handle other errors
				trace("ZMQException #:" + e.errNo + ", str:" + e.str());
				trace (Stack.toString(Stack.exceptionStack()));
			}
		}
		// Close up gracefully
		receiver.close();
		context.term();
		
		
	}
}