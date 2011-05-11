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

import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQException;
import org.zeromq.ZMQPoller;
import org.zeromq.ZMQSocket;

/**
 * ZMQ.ZMQContext class tests
 * 
 * Based on https://github.com/zeromq/pyzmq/blob/master/zmq/tests/test_context.py
 */
class TestContext extends BaseTest
{

	public function testInit() 
	{
		var c1 = ZMQContext.instance();
		assertTrue(Std.is(c1, ZMQContext));
		c1 = null;
		
		var c2 = ZMQContext.instance();
		assertTrue(Std.is(c2, ZMQContext));
		c2 = null;
		
		var c3 = ZMQContext.instance();
		assertTrue(Std.is(c3, ZMQContext));
		c3 = null;
	}
	
	public function testTerm() 
	{
		var c1:ZMQContext = ZMQContext.instance();
		c1.term();
		assertTrue(c1.closed);
	}
	
	public function testFailInit() {
		
		var c1:ZMQContext;
		assertRaisesZMQException(function() c1 = ZMQContext.instance(0),EINVAL);
	}
	
	public function testInstance() {
		var ctx = ZMQContext.instance();
		var c2 = ZMQContext.instance(2);
		assertTrue(Std.is(c2, ZMQContext));
		assertTrue(c2 == ctx);
		c2.term();
		
		var c3:ZMQContext = ZMQContext.instance();
		var c4:ZMQContext = ZMQContext.instance();
		assertFalse(c3 == c2);
		assertFalse(c3.closed);
		assertTrue(c3 == c4);
	}
		
	public function testSocket() {
		var ctx:ZMQContext = ZMQContext.instance();
		var s:ZMQSocket = ctx.socket(ZMQ_PUB);
		
		assertTrue(s != null);
		assertFalse(s.closed);
		s.close();
		
		ctx.term();
		assertRaisesZMQException(function() s = ctx.socket(ZMQ_PUB), ENOTSUP);
		try {
			s = ctx.socket(ZMQ_PUB);
			assertTrue(false);
		} catch (e:ZMQException) {
			assertTrue(e.err == ENOTSUP);
		}
		
	}
	
	public function testPoller() {
		var ctx:ZMQContext = ZMQContext.instance();
		var p:ZMQPoller = ctx.poller();
		
		assertTrue(p != null);
		
		ctx.term();
		assertRaisesZMQException(function() p = ctx.poller(), ENOTSUP);
	}
	
	public override function setup():Void {
		// No setup needed for these tests
	}
	
	public override function tearDown():Void {
		// No tearDown needed for these tests
	}
}