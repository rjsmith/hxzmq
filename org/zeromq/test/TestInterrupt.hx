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

package org.zeromq.test;
import haxe.io.Bytes;
import neko.Sys;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

class TestInterrupt extends BaseTest
{

	public function testInterrupt() {
		
		var context:ZMQContext = ZMQContext.instance();
		var receiver:ZMQSocket = context.socket(ZMQ_REP);
		receiver.bind("tcp://127.0.0.1:5559");
		trace ("About to call catchSignals");
		ZMQ.catchSignals();
		
		print("\nPress Ctrl+C");

		while (true) {
			// Blocking read, will exit only on an interrupt (Ctrl+C)
			var msg:Bytes = receiver.recvMsg();
		
			if (ZMQ.isInterrupted()) {
				assertTrue(true);
				break;
			}
			// Should not get here
			assertTrue(false);
		}
		// Close up gracefully
		receiver.close();
		context.term();
	}
}