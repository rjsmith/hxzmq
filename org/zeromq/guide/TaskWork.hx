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
 * Task worker in Haxe
 * Connects PULL socket to tcp://localhost:5557
 * Collects workloads from ventilator via that socket
 * Connects PUSH socket to tcp://localhost:5558
 * Sends results to sink via that socket
 * 
 * See: http://zguide.zeromq.org/page:all#Divide-and-Conquer
 * 
 * Based on code from: http://zguide.zeromq.org/java:taskwork
 */
class TaskWork 
{

	public static function main() {
		var context:ZMQContext = ZMQContext.instance();

		Lib.println("** TaskWork (see: http://zguide.zeromq.org/page:all#Divide-and-Conquer)");
		
		// Socket to receive messages on
		var receiver:ZMQSocket = context.socket(ZMQ_PULL);
		receiver.connect("tcp://127.0.0.1:5557");

		// Socket to send messages to
		var sender:ZMQSocket = context.socket(ZMQ_PUSH);
		sender.connect("tcp://127.0.0.1:5558");
		
		// Process tasks forever
		while (true) {
			var msgString = StringTools.trim(receiver.recvMsg().toString());
			var sec:Float = Std.parseFloat(msgString) / 1000.0;
			Lib.print(msgString + ".");
			
			// Do the work
			Sys.sleep(sec);
			
			// Send results to sink
			sender.sendMsg(Bytes.ofString(""));
		}
		
		
	}
}