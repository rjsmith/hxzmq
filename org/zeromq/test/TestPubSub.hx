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
import haxe.Stack;
import neko.Sys;

import org.zeromq.ZMQ;
import org.zeromq.ZMQSocket;
import org.zeromq.ZMQException;
import org.zeromq.test.BaseTest;

class TestPubSub extends BaseTest
{

	public function testBasicPubSub() {
		
		try {
			var pair:SocketPair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
			_sockets.add(pair.s1);
			_sockets.add(pair.s2);

			// Subscribe to everything
			pair.s2.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString(""));
			
			Sys.sleep(0.1);
			pair.s1.sendMsg(Bytes.ofString("foo"));
			var msg:Bytes = pair.s2.recvMsg();	// this is a blocking call
			assertTrue(msg.toString() == "foo");
			
			var a:Bytes = Bytes.alloc(1);
			for (i in 0...10) {
				a.set(0, i);
				pair.s1.sendMsg(a);
				msg = pair.s2.recvMsg();
				assertTrue(msg.length == 1);
				assertTrue(msg.get(0) == i);
			}
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
	}
	
	public function testTopic() {
		try {
			var pair:SocketPair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
			_sockets.add(pair.s1);
			_sockets.add(pair.s2);

			var b:Bytes = Bytes.ofString("x");
			pair.s2.setsockopt(ZMQ_SUBSCRIBE, b);
			Sys.sleep(0.1); // make sure subscriber gets first message published by publisher
			
			pair.s1.sendMsg(Bytes.ofString("message"));	// send message that shouldnt meet the subscribe filter
			pair.s1.sendMsg(Bytes.ofString("xmessage"));	// send message that should meet the subscribe filter
			var msg:Bytes = pair.s2.recvMsg(DONTWAIT); // This is a non-blocking call
			assertTrue(msg == null);
			
			msg = pair.s2.recvMsg();	// this is a blocking call
			assertTrue(msg != null);
			assertTrue(msg.toString() == "xmessage");
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
					
	}
}