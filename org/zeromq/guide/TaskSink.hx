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
 * Task sink in Haxe
 * Binds PULL request socket to tcp://localhost:5558
 * Collects results from workers via this socket
 * 
 * See: http://zguide.zeromq.org/page:all#Divide-and-Conquer
 * 
 * Based on http://zguide.zeromq.org/java:tasksink
 */
class TaskSink 
{

	public static function main() {
		var context:ZMQContext = ZMQContext.instance();

		Lib.println("** TaskSink (see: http://zguide.zeromq.org/page:all#Divide-and-Conquer)");
		
		// Socket to receive messages on
		var receiver:ZMQSocket = context.socket(ZMQ_PULL);
		receiver.bind("tcp://127.0.0.1:5558");
		
		// Wait for start of batch
		var msgString = StringTools.trim(receiver.recvMsg().toString());
		
		// Start our clock now
		var tStart = Sys.time();
		
		// Process 100 messages
		var task_nbr:Int;
		for (task_nbr in 0 ... 100) {
			msgString = StringTools.trim(receiver.recvMsg().toString());
			if (task_nbr % 10 == 0) {
				Lib.println(":");		// Print a ":" every 10 messages
			} else {
				Lib.print(".");
			}
		}
		// Calculate and report duation of batch
		var tEnd = Sys.time();
		Lib.println("Total elapsed time: " + Math.ceil((tEnd - tStart) * 1000) + " msec");
		
		receiver.close();
		context.term();
	}
}