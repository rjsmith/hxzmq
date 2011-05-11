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

package org.zeromq.guide;

import haxe.io.Bytes;
import haxe.Stack;
import neko.Lib;
import neko.Sys;
import neko.vm.Thread;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQPoller;
import org.zeromq.ZMQSocket;

/**
 * Multithreaded Hello World Server
 * 
 * See: http://zguide.zeromq.org/page:all#Multithreading-with-MQ
 */
class MTServer 
{

	static function worker() {
		var context:ZMQContext = ZMQContext.instance();
		
		// Socket to talk to dispatcher
		var responder:ZMQSocket = context.socket(ZMQ_REP);
		responder.connect("inproc://workers");
		
		ZMQ.catchSignals();
		
		while (true) {
			
			try {
				// Wait for next request from client
				var request:Bytes = responder.recvMsg();
				
				trace ("Received request:" + request.toString());
				
				// Do some work
				Sys.sleep(1);
				
				// Send reply back to client
				responder.sendMsg(Bytes.ofString("World"));
			} catch (e:ZMQException) {
				if (ZMQ.isInterrupted()) {
					break;
				}
				trace (e.toString());
			}
		} 
		responder.close();
		return null;
	}
	
	/**
	 * Implements a reqeust/reply QUEUE broker device
	 * Returns if poll is interrupted
	 * @param	ctx
	 * @param	frontend
	 * @param	backend
	 */
	static function queueDevice(ctx:ZMQContext, frontend:ZMQSocket, backend:ZMQSocket) {
		
		// Initialise pollset
		var poller:ZMQPoller = ctx.poller();
		poller.registerSocket(frontend, ZMQ.ZMQ_POLLIN());
		poller.registerSocket(backend, ZMQ.ZMQ_POLLIN());
		
		ZMQ.catchSignals();
		
		while (true) {
			try {
				poller.poll();
				if (poller.pollin(1)) {
					var more:Bool = true;
					while (more) {
						// Receive message
						var msg = frontend.recvMsg();
						more = frontend.hasReceiveMore();
						
						// Broker it
						backend.sendMsg(msg, { if (more) SNDMORE else null; } );
					}
				}
				
				if (poller.pollin(2)) {
					var more:Bool = true;
					while (more) {
						// Receive message
						var msg = backend.recvMsg();
						more = backend.hasReceiveMore();
						
						// Broker it
						frontend.sendMsg(msg, { if (more) SNDMORE else null; } );
					}
				}
			} catch (e:ZMQException) {
				if (ZMQ.isInterrupted()) {
					break;
				}
				// Handle other errors
				trace("ZMQException #:" + e.errNo + ", str:" + e.str());
				trace (Stack.toString(Stack.exceptionStack()));
				
			}

		}
		
	}
	public static function main() {
		var workerThreads:List<Thread> = new List<Thread>();
		
		var context:ZMQContext = ZMQContext.instance();
		
		Lib.println ("** MTServer (see: http://zguide.zeromq.org/page:all#Multithreading-with-MQ)");
		
		// Socket to talk to clients
		var clients:ZMQSocket = context.socket(ZMQ_ROUTER);
		clients.bind ("tcp://*:5556");
		
		// Socket to talk to workers
		var workers:ZMQSocket = context.socket(ZMQ_DEALER);
		workers.bind ("inproc://workers");
		
		// Launch worker thread pool
		for (thread_nbr in 0 ... 5) {
			workerThreads.add(Thread.create(worker));
		}
		
		// Invoke request / reply broker (aka QUEUE device) to connect clients to workers
		queueDevice(context, clients, workers);
		
		// Close up shop
		clients.close();
		workers.close();
		context.term();
	}
}