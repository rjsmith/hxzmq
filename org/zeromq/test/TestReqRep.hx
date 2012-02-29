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
import StringTools;
import haxe.Stack;
import neko.Sys;

import org.zeromq.ZMQ;
import org.zeromq.ZMQSocket;
import org.zeromq.ZMQException;
import org.zeromq.test.BaseTest;

/**
 * Test class for REQ and REP socket types.
 * 
 * Based on https://github.com/zeromq/pyzmq/blob/master/zmq/tests/test_reqrep.py
 */
class TestReqRep extends BaseTest
{

	public function testBasicReqRep() {
		var pair:SocketPair;
		try {
			pair = createBoundPair(ZMQ_REQ, ZMQ_REP);
			var msg1:Bytes = Bytes.ofString("message1");
			
			var msg2:Bytes = ping_pong(pair, msg1);
			assertTrue(StringTools.startsWith(msg2.toString(),msg1.toString()));
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
	}
	
	public function testMultiple() {
		var pair:SocketPair;
		var msg1,msg2:Bytes;
		
		try {
			pair = createBoundPair(ZMQ_REQ, ZMQ_REP);
			for (i in 9...12) {
				msg1 = Bytes.ofString(i + " ");
				msg2 = ping_pong(pair, msg1);
				assertTrue(StringTools.startsWith(msg2.toString(),msg1.toString()));	
			}
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
		
	}
	
	public function testBadSendRcv() {
		var pair:SocketPair;
		try {
			pair = createBoundPair(ZMQ_REQ, ZMQ_REP);
			
			//TODO: Why is this raising a Invalid argument (mutex.hpp:98) ereror at runtime?
			assertRaisesZMQException(function() { pair.s1.recvMsg(); }, EFSM);	// Try receiving on a REQ socket
			assertRaisesZMQException(function() { pair.s2.sendMsg(Bytes.ofString("foo")); }, EFSM);	// Try sending on a REP socket before receiving request
			
			// Added to prevent an abort trap being raised when we run the test
			// See: https://github.com/zeromq/pyzmq/blob/master/zmq/tests/test_reqrep.py
			var msg1:Bytes = Bytes.ofString("message1");
			var msg2:Bytes = ping_pong(pair, msg1);
			assertTrue(StringTools.startsWith(msg2.toString(),msg1.toString()));
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}		
	}
	
	public function testLargeMessage() {
		var pair:SocketPair;
		try {
			pair = createBoundPair(ZMQ_REQ, ZMQ_REP);
			
			var b:StringBuf = new StringBuf();
			
			//TODO: Fails when set >= 6922
			for (c in 0...1000) {
				b.add("x");
			}
			
			var msg1:Bytes = Bytes.ofString(b.toString());
			for (i in 0...10) {
				var msg2:Bytes = ping_pong(pair, msg1);
				assertTrue(StringTools.startsWith(msg2.toString(),msg1.toString()));	
			}
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
		
	}
	
	
}