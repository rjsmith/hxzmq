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
import org.zeromq.ZContext;
import org.zeromq.ZMQSocket;

import haxe.Stack;

/**
 * Tests high-level ZContext context management class
 */
class TestZContext extends BaseTest
{

    public function testConstruction() {
        
        var ctx:ZContext = new ZContext();
        assertTrue(ctx != null);
        assertEquals(1, ctx.ioThreads);
        assertEquals(0, ctx.linger);
        assertTrue(ctx.main);
              
        ctx.destroy();
    }
    
    public function testDestruction() {
        var ctx:ZContext = new ZContext();
        ctx.destroy();
        assertTrue(ctx.sockets.isEmpty());
        
        // Ensure context not destroyed if not in main thread
        var ctx1:ZContext = new ZContext();
        ctx1.main = false;
        var s:ZMQSocket = ctx1.newSocket(ZMQ_PUB);
        ctx1.destroy();
        assertFalse(ctx1.context.closed);
    }
    
    public function testAddingSockets() {
        // tests "internal" newSocket method, should not be used outside hxzmq itself
        var ctx:ZContext = new ZContext();
        try {
            var s:ZMQSocket = ctx.newSocket(ZMQ_PUB);
            assertTrue(s != null);
            assertFalse(s.closed);
            var s1:ZMQSocket = ctx.newSocket(ZMQ_REQ);
            assertTrue(s1 != null);
            assertEquals(2, ctx.sockets.length);
        } catch (e:ZMQException) {
            trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
        }
        ctx.destroy();
        
    }
    
    public function testRemovingSockets() {
        // tests "internal" newSocket method, should not be used outside hxzmq itself
        var ctx:ZContext = new ZContext();
        try {
            var s:ZMQSocket = ctx.newSocket(ZMQ_PUB);
            assertTrue(s != null);
            assertEquals(1, ctx.sockets.length);
            
            ctx.destroySocket(s);
            assertEquals(0, ctx.sockets.length);
            assertTrue(s.closed);
            
        } catch (e:ZMQException) {
            trace("ZMQException #:" + e.errNo + ", str:" + e.str());
			trace (Stack.toString(Stack.exceptionStack()));
			assertTrue(false);
        }
        ctx.destroy();
        
    }
    
    public function testShadow() {
        var ctx:ZContext = new ZContext();
        var s:ZMQSocket = ctx.newSocket(ZMQ_PUB);
        assertTrue(s != null);
        assertEquals(ctx.sockets.length, 1);
        
        var shadowCtx = ZContext.shadow(ctx);
        assertEquals(0, shadowCtx.sockets.length);
        assertTrue(ctx.context == shadowCtx.context);
        var s1:ZMQSocket = shadowCtx.newSocket(ZMQ_SUB);
        assertEquals(1, shadowCtx.sockets.length);
        assertEquals(1, ctx.sockets.length); 
    }
    
	public override function setup():Void {
		// No setup needed for these tests
	}
	
	public override function tearDown():Void {
		// No tearDown needed for these tests
	}
    
}