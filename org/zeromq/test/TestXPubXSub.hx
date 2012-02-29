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
import haxe.io.BytesBuffer;
import haxe.Stack;
import neko.Sys;
import org.zeromq.ZMsg;

import org.zeromq.ZMQ;
import org.zeromq.ZMQSocket;
import org.zeromq.ZMQException;
import org.zeromq.test.BaseTest;

/**
 * This class sets up tests for the XPUB and XSUB socket types
 * introduced in 0MQ3
 */
class TestXPubXSub extends BaseTest
{

	public function testSubscriptionForwarding() {
		
		try {
			var pair:SocketPair = createBoundPair(ZMQ_XPUB, ZMQ_XSUB);
			_sockets.add(pair.s1);
			_sockets.add(pair.s2);

			pair.s2.setsockopt(ZMQ_RCVTIMEO, 100);	// Timeout blocking recv on XSUB socket at 100msecs.
													// Used for filtered-out test below
													
			// Subscribe to prefix "A"
			var subscription:BytesBuffer = new BytesBuffer();
			subscription.addByte(1);	// Subscribe
			subscription.add(Bytes.ofString("A"));
			pair.s2.sendMsg(subscription.getBytes());
						
			Sys.sleep(0.1); // Give time for XPUB socket to receive subscription
			var sent = new ZMsg();
			sent.addString("A");
			sent.addString("I want to receive this");
			sent.send(pair.s1);
			
			var msg:ZMsg = ZMsg.recvMsg(pair.s2);	// this is a blocking call
			assertTrue(msg.first().streq("A"));
			assertTrue(msg.last().streq("I want to receive this"));
			
			// Send a message to XSUB socket that should not meet its subscription
			sent = new ZMsg();
			sent.addString("B");
			sent.addString("I don't want to receive this");
			sent.send(pair.s1);
			
			// This call should time out
			msg = null;
			msg = ZMsg.recvMsg(pair.s2);
			assertTrue(msg == null);
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
	}
	
}