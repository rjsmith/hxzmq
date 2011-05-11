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
import haxe.unit.TestCase;
import haxe.PosInfos;

import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;
import org.zeromq.ZMQException;

/**
 * Utility methods.
 * 
 * Based on https://github.com/zeromq/pyzmq/blob/master/zmq/tests/__init__.py
 */
class BaseTest extends TestCase
{

	private var _context:ZMQContext;
	private var _sockets:List<ZMQSocket>;
	
	public override function setup():Void {
		_context = ZMQContext.instance();
		_sockets = new List<ZMQSocket>();
	}
	
	public override function tearDown():Void {
		var _contexts:List<ZMQContext> = new List<ZMQContext>();
		var s:ZMQSocket;
		var _ctx:ZMQContext;
		
		_contexts.add(_context);
		for (s in _sockets) {
			_contexts.add(s.context);
			s.close();
		}
		_sockets = null;
		for (_ctx in _contexts) {
			_ctx.term();
		}
		
	}
	
	/**
	 * Create a bound ZMQ socket pair using a random port
	 * @param	type1
	 * @param	type2
	 * @param	?interface
	 */
	public function createBoundPair(type1:SocketType, type2:SocketType, ?iface:String = 'tcp://127.0.0.1'): SocketPair {
		if (_context == null || _context.closed) {
			assertTrue(false);
			return null;
		}
		
		var randomPort:Int = Math.round(Math.random() * 18000) + 2000;
		var _s1:ZMQSocket = _context.socket(type1); 
		_s1.setsockopt(ZMQ_LINGER, 0);
		var _p1 = bindToRandomPort(_s1, iface);
		var _s2:ZMQSocket = _context.socket(type2); 
		_s2.setsockopt(ZMQ_LINGER, 0);
		_s2.connect(iface + ":" + _p1);
		_sockets.add(_s1);
		_sockets.add(_s2);
		return { s1:_s1, s2:_s2 };
	}
	
	/**
	 * Send a message from p.s1 to p.s2, then send it back again from s2 to s1
	 * @param	p		SocketPair
	 * @param	msg		original message to ping pong
	 * @return 	ping-ponged message
	 */
	public function ping_pong(p:SocketPair, msg:Bytes):Bytes {
		//trace ("s1.sendMsg:"+msg.toString());
		p.s1.sendMsg(msg);
		//trace ("s2.recvMsg");
		var msg2:Bytes = p.s2.recvMsg();
		//trace ("s2.sendMsg:"+msg2.toString());
		p.s2.sendMsg(msg2);
		//trace ("s1.recvMsg");
		var msg3:Bytes = p.s1.recvMsg();
		//trace ("return");
		return msg3;
	}
	
	/**
	 * Binds a socket to a random port in range
	 * @param	s
	 * @param	addr
	 * @param	?minPort = 2000
	 * @param	?maxPort = 20000
	 * @param	?maxTries = 100
	 * @return
	 */
	private function bindToRandomPort(s:ZMQSocket, addr:String, ?minPort = 2000, ?maxPort = 20000, ?maxTries = 100):Int {
		var _iter = new IntIter(1, maxTries);
		var _port = minPort;
		
		for (i in _iter) {
			try {
				_port = Math.round(Math.random() * (maxPort - minPort)) + minPort;
				s.bind(addr + ":" + _port);
				return _port;
			} catch (e:ZMQException) {
				// Ignore error. Go round and try another port
			}
		}
		throw new String("Could not bind socket to random port");
		return null;
	}
	
	function assertRaisesZMQException(fn:Void->Void, err:ErrorType, ?c : PosInfos):Void {
	
		var res = "";
		
        currentTest.done = true;
		try {
			fn();
			res = "no exception";
		}
		catch (e:ZMQException) {
			if (e.err == err) {
				assertTrue(true);
				return;
			} 
			res = "ZMQException errNo:" + e.errNo + ", str:" + e.str();
		} catch (e:Dynamic) {
			res = e;
		}
		
		currentTest.success = false;
		currentTest.error   = "expected "+err+" but got "+res+" instead";
		currentTest.posInfos = c;
		throw currentTest;

	}
}

typedef SocketPair = { s1:ZMQSocket, s2:ZMQSocket };