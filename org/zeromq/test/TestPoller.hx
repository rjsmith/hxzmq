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
import neko.Sys;
import haxe.Stack;

import org.zeromq.ZMQ;
import org.zeromq.ZMQPoller;
import org.zeromq.ZMQException;

import org.zeromq.test.BaseTest;

class TestPoller extends BaseTest
{

	public function testRegistering() {
		
		var pair:SocketPair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
		
		// Create Poller object
		var poller:ZMQPoller = new ZMQPoller();
		assertTrue(poller != null);
		
		poller.registerSocket(pair.s2, ZMQ.ZMQ_POLLIN());		
		poller.registerSocket(pair.s1, ZMQ.ZMQ_POLLOUT());
		assertEquals(2, poller.getSize());
		
		assertEquals(true, poller.unregisterSocket(pair.s2));
		assertEquals(1, poller.getSize());
		
		poller.unregisterAllSockets();
		assertEquals(0, poller.getSize());
	}
	
	public function testPollingPairPair() {
		
		var pair:SocketPair = createBoundPair(ZMQ_PAIR, ZMQ_PAIR);
		var pollinout:Int = ZMQ.ZMQ_POLLIN() | ZMQ.ZMQ_POLLOUT();
		try {
			Sys.sleep(0.1);	// Allow sockets time to connect
			
			var poller:ZMQPoller = new ZMQPoller();
			poller.registerSocket(pair.s1, pollinout);
			poller.registerSocket(pair.s2, pollinout);
			
			var numSocks = poller.poll();
			assertEquals(2, numSocks);
			assertEquals(2, poller.revents.length);
			assertTrue(poller.pollout(1));		// PAIR socket s1 should be ready for writing
			assertTrue(poller.pollout(2));		// PAIR socket s2 should be ready for writing
			
			// Now do a send on both, wait and test for POLLOUT|POLLIN
			pair.s1.sendMsg(Bytes.ofString("msg1"));
			pair.s2.sendMsg(Bytes.ofString("msg2"));
			Sys.sleep(0.1);
			
			numSocks = poller.poll();
			assertTrue(poller.pollin(1) && poller.pollout(1));		// PAIR socket s1 should be ready for reading & writing
			assertTrue(poller.pollin(2) && poller.pollout(2));		// PAIR socket s2 should be reasy for reading & writing
			
			// Make sure both are in POLLOUT after recv
			var msg1 = pair.s1.recvMsg();
			var msg2 = pair.s2.recvMsg();
			numSocks = poller.poll();
			assertTrue(poller.pollout(1));		// PAIR socket s1 should be ready for writing
			assertTrue(poller.pollout(2));		// PAIR socket s2 should be ready for writing
			
			poller.unregisterAllSockets();
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
	}
	
	public function testPollingReqRep() {
		
		var pair:SocketPair = createBoundPair(ZMQ_REP, ZMQ_REQ);
		var pollinout:Int = ZMQ.ZMQ_POLLIN() | ZMQ.ZMQ_POLLOUT();
		try {
			Sys.sleep(0.1);	// Allow sockets time to connect
			
			var poller:ZMQPoller = new ZMQPoller();
			poller.registerSocket(pair.s1, pollinout);
			poller.registerSocket(pair.s2, pollinout);
			
			var numSocks = poller.poll();
			assertEquals(1, numSocks);								// Only one revent bitmask with an event
			assertEquals(2, poller.getSize());
			assertTrue(poller.noevents(1));						// REP socket s1 no events
			assertTrue(poller.pollout(2));		// REQ socket s2 should be ready for writing
			
			// Make sure s2 REQ socket immediately goes into state 0 after send
			pair.s2.sendMsg(Bytes.ofString("msg1"));
			numSocks = poller.poll();
			assertTrue(poller.noevents(2));

			// Make sure that s1 goes into POLLIN state after a sleep()
			Sys.sleep(0.1);
			numSocks = poller.poll();
			assertTrue(poller.pollin(1));

			// Make sure s1 REP socket goes into POLLOUT after recv
			var msg1 = pair.s1.recvMsg();
			numSocks = poller.poll();
			assertTrue(poller.pollout(1));

			// Make sure s1 REP socket immediately goes into state 0 after send
			pair.s1.sendMsg(Bytes.ofString("msg2"));
			numSocks = poller.poll();
			assertTrue(poller.noevents(1));

			// Make sure that s2 goes into POLLIN state after a sleep()
			Sys.sleep(0.1);
			numSocks = poller.poll();
			assertTrue(poller.pollin(2));

			// Make sure s2 REQ socket goes into POLLOUT after recv
			var msg1 = pair.s2.recvMsg();
			numSocks = poller.poll();
			assertTrue(poller.pollout(2));
			
			poller.unregisterAllSockets();
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
		
	}
	
	public function testPollingPubSub() {
		var pair:SocketPair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
		var pollinout:Int = ZMQ.ZMQ_POLLIN() | ZMQ.ZMQ_POLLOUT();
		try {
			pair.s2.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString(""));
			Sys.sleep(0.1);	// Allow sockets time to connect
			
			var poller:ZMQPoller = new ZMQPoller();
			poller.registerSocket(pair.s1, pollinout);
			poller.registerSocket(pair.s2, ZMQ.ZMQ_POLLIN());
			
			// Makes sure only first is send ready
			var numSocks = poller.poll();
			assertTrue(poller.pollout(1));
			assertTrue(poller.noevents(2));
			
			// Make sure s1 stays in POLLOUT after send
			pair.s1.sendMsg(Bytes.ofString("msg1"));
			numSocks = poller.poll();
			assertTrue(poller.pollout(1));

			// Make sure SUB s2 is ready for reading
			Sys.sleep(0.1);
			numSocks = poller.poll();
			assertTrue(poller.pollin(2));
			
			var msg2:Bytes = pair.s2.recvMsg();
			numSocks = poller.poll();
			assertTrue(poller.noevents(2));
			
			poller.unregisterAllSockets();

		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
			
		
	}
}