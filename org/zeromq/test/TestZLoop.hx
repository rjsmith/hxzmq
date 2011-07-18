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
import org.zeromq.ZLoop;
import org.zeromq.ZContext;
import org.zeromq.ZMsg;

class TestZLoop extends BaseTest
{

    public function testBasic() {
        var ctx:ZContext = new ZContext();
        
        var output:ZMQSocket = ctx.createSocket(ZMQ_PAIR);
        ZSocket.bindEndpoint(output, "inproc", "zloop.test");
        var input:ZMQSocket = ctx.createSocket(ZMQ_PAIR);
        ZSocket.connectEndpoint(input, "inproc", "zloop.test");

        var here = this;

        var loop:ZLoop = new ZLoop();
        assertTrue(loop != null);
        
		// Change to verbose = true to see zloop polling trace info
        loop.verbose = false;
        
        var timerEventFn = function (loop:ZLoop,args:Dynamic):Int {
            ZMsg.newStringMsg("PING with args:"+args).send(output);
            return 0;
        };
       
        var socketEventFn = function(loop:ZLoop, output:ZMQSocket):Int {
            return -1;  // End the reactor
        }
        
        // After 10 msec, send a ping message to output
        assertTrue(loop.registerTimer(10, 1, timerEventFn, "HELLO"));
        
        var pollInput:PollItemT = { socket:input, event:ZMQ.ZMQ_POLLIN() };
        assertTrue(loop.registerPoller(pollInput, socketEventFn));
        
        loop.start();
        
        // end
        assertTrue(true);
        loop.destroy();
        ctx.destroy();
    }
}