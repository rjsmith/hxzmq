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

import haxe.Stack;
import haxe.io.Bytes;

import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;
import org.zeromq.ZMQException;
import org.zeromq.test.BaseTest;

/**
 * Haxe test class focused on the ZMQSocket haxe binding class
 * 
 * Assumes a baseline ZMQ version of 3.x.x (ie. some tests may not execute or compile if run against any earlier versions of the libzmq library)
 */
class TestSocket extends BaseTest
{

	public function testCreate() {
		var ctx:ZMQContext = ZMQContext.instance();
		var s:ZMQSocket = ctx.socket(ZMQ_PUB);
		
		assertTrue(s != null);
		assertFalse(s.closed);
				
		// Test bind to invalid protocol
		assertRaisesZMQException(function() s.bind("ftl://a"), #if php ENOTSUP #else EPROTONOSUPPORT #end);
		assertRaisesZMQException(function() s.bind("tcp://"),#if php ENOTSUP #else EINVAL #end);
		assertRaisesZMQException(function() s.connect("ftl://a"),#if php ENOTSUP #else EPROTONOSUPPORT #end);
		
		s.close();
		
		assertTrue(s.closed);
		
	}
	
	public function testClose() {
		var ctx:ZMQContext = ZMQContext.instance();
		var s:ZMQSocket = ctx.socket(ZMQ_PUB);
		s.close();
		assertTrue(s.closed);
		
		assertRaisesZMQException(function() s.bind("") , ENOTSUP);
		assertRaisesZMQException(function() s.connect(""), ENOTSUP);
	}
	
	public function testBoundPair() {
		var pair:SocketPair = null;
		
		try {
			pair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
		assertTrue(pair != null);
		assertTrue(!pair.s1.closed);
		assertTrue(!pair.s2.closed);		
		
	}
	
	public function testIntSocketOptions() {
		var pair:SocketPair = null;
		
		try {
			pair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
			pair.s1.setsockopt(ZMQ_LINGER, 0);
			assertTrue(pair.s1.getsockopt(ZMQ_LINGER) == 0);
#if not php            
            // Setting ZMQ_LINGER to -1 not supported in php-zmq 0.7.0, although since fixed on master branch
			pair.s1.setsockopt(ZMQ_LINGER, -1);
			assertTrue(pair.s1.getsockopt(ZMQ_LINGER) == -1);
            // ZMQ_EVENTS not supported in php-zmq 0.7.0
			var r:Int = pair.s1.getsockopt(ZMQ_EVENTS);
			assertEquals(ZMQ.ZMQ_POLLOUT(), r);
			assertRaisesZMQException(function() { pair.s1.setsockopt(ZMQ_EVENTS, 2 ^ 7 - 1); }, EINVAL);
			
			pair.s1.setsockopt(ZMQ_LINGER, 0);
			r = pair.s1.getsockopt(ZMQ_SNDHWM);
			assertTrue(r == 0);	// Test default HWM is 0 for a new socket
			pair.s2.setsockopt(ZMQ_SNDHWM, 10 );
			var r:Int = pair.s2.getsockopt(ZMQ_SNDHWM);
			assertEquals(10, r);
			
#end            
			assertEquals(ZMQ.socketTypeNo(ZMQ_PUB), pair.s1.getsockopt(ZMQ_TYPE));
			assertEquals(ZMQ.socketTypeNo(ZMQ_SUB), pair.s2.getsockopt(ZMQ_TYPE));	
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
	}

	public function testInt64SocketOptions() {
		var pair:SocketPair = null;        
        var v1, v2:Int;
#if (neko || cpp)
		var r:ZMQInt64Type = null;

#elseif php            
		var r:Int = null;
        var intsize = untyped __php__('PHP_INT_SIZE');
#end            
		
		try {
			pair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
#if (neko || cpp)   
			pair.s1.setsockopt(ZMQ_MAXMSGSIZE, { hi:10, lo:100 } );
			r = pair.s1.getsockopt(ZMQ_MAXMSGSIZE);
			assertEquals(10, r.hi);
			assertEquals(100, r.lo);
			
			r = pair.s1.getsockopt(ZMQ_AFFINITY);
			assertEquals(0, r.lo);			
#elseif php            
			pair.s1.setsockopt(ZMQ_LINGER, 0);
			r = pair.s1.getsockopt(ZMQ_HWM);
			assertTrue(r == 0);	// Test default HWM is 0 for a new socket
            // If PHP int is 64bits, try a larger int value, else try a 32bit number.
            v1 = { if (intsize == 8) (128 * 2 ^ 32) + 128;  else 128; };
			pair.s2.setsockopt(ZMQ_HWM, v1 );
			var r:Int = pair.s2.getsockopt(ZMQ_HWM);
			assertTrue(r == v1);
			r = pair.s1.getsockopt(ZMQ_AFFINITY);
			assertEquals(0, r);			
			r = pair.s1.getsockopt(ZMQ_SWAP);
			assertTrue(r == 0);
            v2 = { if (intsize == 8) (2 ^ 32) + 128;  else 128; };
			pair.s1.setsockopt(ZMQ_SWAP, v2 );    
			r = pair.s1.getsockopt(ZMQ_SWAP);
			assertTrue(r == v2);
#end			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}

	}
	
	public function testBytesSocketOptions() {
		var pair:SocketPair = null;

		try {
			pair = createBoundPair(ZMQ_PUB, ZMQ_SUB);
			pair.s2.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString("foo"));
			
			// Test that you cannot retrieve a previously sefined SUBSCRIBE option value using getsockopt
			// See: http://api.zeromq.org/2-1-3:zmq-getsockopt
			assertRaisesZMQException(function() pair.s2.getsockopt(ZMQ_SUBSCRIBE),#if php ENOTSUP #else EINVAL #end);
			
			pair.s1.setsockopt(ZMQ_IDENTITY, Bytes.ofString("Socket1"));
			var b:Bytes = pair.s1.getsockopt(ZMQ_IDENTITY);
			assertEquals("Socket1", b.toString());
			
		} catch (e:ZMQException) {
			trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
		}
	}
	public function testSendBasic() {
		
		try {
			var pair:SocketPair = createBoundPair(ZMQ_PAIR, ZMQ_PAIR);
			pair.s1.setsockopt(ZMQ_LINGER, 0);
			pair.s2.setsockopt(ZMQ_LINGER, 0);
			pair.s1.sendMsg(Bytes.ofString("foo"));
			var msg:Bytes = pair.s2.recvMsg();
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

	
	
}