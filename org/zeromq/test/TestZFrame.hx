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

import org.zeromq.ZMQ;
import org.zeromq.ZContext;
import org.zeromq.ZFrame;
import org.zeromq.ZSocket;
import org.zeromq.ZFrame;
import org.zeromq.ZMQSocket;

class TestZFrame extends BaseTest
{

    public function testZFrameCreation() {
        var f:ZFrame = new ZFrame(Bytes.ofString("Hello"));
        assertTrue(f != null);
        assertEquals(5, f.size());
    }
    
    public function testSendingReceiving() {
        var ctx:ZContext = new ZContext();
        var output:ZMQSocket = ZSocket.create(ctx, ZMQ_PAIR);
        ZSocket.bind(output, "inproc", "zframe.test");
        var input:ZMQSocket = ZSocket.create(ctx, ZMQ_PAIR);
        ZSocket.connect(input, "inproc", "zframe.test");
        
        // Send five different frames, test ZFRAME_MORE
        for (frameNBR in 0 ... 5) {
            var f:ZFrame = new ZFrame(Bytes.ofString("Hello"));
            f.send(output, ZFrame.ZFRAME_MORE);
            assertTrue(f.size() == 0);
        }
        
        // Send same frame five times
        var f:ZFrame = new ZFrame(Bytes.ofString("Hello"));
        for (frameNBR in 0 ... 5) {
            f.send(output, ZFrame.ZFRAME_MORE + ZFrame.ZFRAME_REUSE);
        }
        assertTrue(f.size() == 5);
        
        // Copy & duplicate
        var copy:ZFrame = f.duplicate();
        assertTrue(copy.equals(f));
        f.destroy();
        assertFalse(copy.equals(f));
        assertEquals(5, copy.size());
        copy.destroy();
        assertFalse(copy.equals(f));
        
        // Send END frame
        f = new ZFrame(Bytes.ofString("NOT"));
        f.reset(Bytes.ofString("END"));
        assertEquals(f.strhex(), "454E44");
        f.send(output);
        
        // Read and count until we received END
        var frame_nbr:Int = 0;
        while (true) {
            f = ZFrame.recvFrame(input);
            frame_nbr++;
            if (f.streq("END")) {
                f.destroy();
                break;
            }
            assertTrue(f.more);
            f.destroy();
        }
        assertEquals(11, frame_nbr);
        f = ZFrame.recvFrameNoWait(input);
        assertTrue(!f.hasData());
        
        ctx.destroy();
    }
}