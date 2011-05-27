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

import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

/**
 * Weather proxy device.
 * 
 * See: http://zguide.zeromq.org/page:all#A-Publish-Subscribe-Proxy-Server
 * 
 * Use with WUClient and WUServer
 */
class WUProxy 
{

    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
		Lib.println("** WUProxy (see: http://zguide.zeromq.org/page:all#A-Publish-Subscribe-Proxy-Server)");
        
        // This is where the weather service sits
        var frontend:ZMQSocket = context.socket(ZMQ_SUB);
        frontend.connect("tcp://localhost:5556");
        
        // This is our public endpoint for subscribers
        var backend:ZMQSocket = context.socket(ZMQ_PUB);
        backend.bind("tcp://10.1.1.0:8100");
        
        // Subscribe on everything
        frontend.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString(""));
        
        var more = false;
        var msgBytes:Bytes;
        
        ZMQ.catchSignals();
        
        var stopped = false;
        while (!stopped) {
            try {
                msgBytes = frontend.recvMsg();
                more = frontend.hasReceiveMore();
                
                // proxy it
                backend.sendMsg(msgBytes, { if (more) SNDMORE else null; } );
                if (!more) {
                    stopped = true;
                }
 			} catch (e:ZMQException) {
				if (ZMQ.isInterrupted()) {
					stopped = true;
				} else {
                    // Handle other errors
                    trace("ZMQException #:" + e.errNo + ", str:" + e.str());
                    trace (Stack.toString(Stack.exceptionStack()));
                }
			}
       }
       frontend.close();
       backend.close();
       context.term();
    }
}