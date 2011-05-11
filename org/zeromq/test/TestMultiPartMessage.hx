/**
 * (c) $(CopyrightDate) Richard J Smith
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
import haxe.Stack;

import org.zeromq.ZMQ;
import org.zeromq.ZMQException;
import org.zeromq.test.BaseTest;

class TestMultiPartMessage extends BaseTest
{

	public function testMultiPartMessage() 
	{
		var pair:SocketPair = null;

		try {
			pair = createBoundPair(ZMQ_REQ, ZMQ_REP);
			pair.s1.setsockopt(ZMQ_LINGER, 0);
			pair.s2.setsockopt(ZMQ_LINGER, 0);

			var msg1:Bytes = Bytes.ofString("message1");
			var msg2:Bytes = Bytes.ofString("message2");
			var msg3:Bytes = Bytes.ofString("message3");
			pair.s1.sendMsg(msg1, SNDMORE);	// 1st part of multipart message
			pair.s1.sendMsg(msg2, SNDMORE);	// 2nd part of multipart message
			pair.s1.sendMsg(msg3);				// last part of multipart message
			
			// Receive multipart message
			var i:Int = 1;
			do {
				var b:Bytes = pair.s2.recvMsg();	// Blocking call
				assertEquals(Std.string(i), b.toString().charAt(7));
				i++;
			} while (pair.s2.hasReceiveMore());
			assertTrue(i == 4); 	// 3 parts received
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.toString());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
	}
	
}