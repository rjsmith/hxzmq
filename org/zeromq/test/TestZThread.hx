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
import haxe.Stack;
import haxe.io.Bytes;
import neko.Sys;
import org.zeromq.ZContext;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;
import org.zeromq.ZMQSocket;
import org.zeromq.ZThread;

/**
 * Haxe test class focussing on ZThread class
 */
class TestZThread extends BaseTest
{

	private function detachedThreadTest(args:Dynamic) {
		// Create a socket to check it'll be automatically deleted
		assertEquals("foo", args);
		var ctx = new ZContext();
		var push = ctx.createSocket(ZMQ_PUSH);
		ctx.destroy();
		assertTrue(push.closed);
	}
	
	private function attachedThreadTest(ctx:ZContext, pipe:ZMQSocket, args:Dynamic) {
		// Create a new socket to check it'll be automatically deleted
		var newSocket = ctx.createSocket(ZMQ_PUSH);
		trace ("newSocket created");
		// Wait for our parent to ping us and pong back
		var ping = pipe.recvMsg();
		trace ("ping received:" + ping.toString());
		pipe.sendMsg(Bytes.ofString("pong"));
		trace ("pipe sent pong");
	}
	
	public function testZThreadDetach() {
		var ctx = new ZContext();

		// Create a new detached thread and let it run
		ZThread.detach(detachedThreadTest, "foo");
		Sys.sleep(0.1);	// 100ms
		
		ctx.destroy();
	}
	
	public function testZThreadAttach() {
		var ctx = new ZContext();

		// Create a new attached thread and let it run
		var pipe:ZMQSocket = ZThread.attach(ctx, attachedThreadTest, "foo");
		trace ("Now send ping");
		pipe.sendMsg(Bytes.ofString("ping"));
		var pong = pipe.recvMsg();
		trace ("pong received:" + pong.toString());
		assertEquals(pong.toString(), "pong");
		
		// Everything should be cleanly closed now
		trace ("exiting");
		try {
			ctx.destroy();
		} catch (e:ZMQException) {
			if (ZMQ.isInterrupted())
				return;		// Interrupted
			else
				trace("ZMQException #:" + e.errNo + ", str:" + e.str());
				trace (Stack.toString(Stack.exceptionStack()));
		}
		
	}
	
		
	public override function setup():Void {
		// Do nothing
	}
	
	public override function tearDown():Void {
		// Do nothing
	}
	
}