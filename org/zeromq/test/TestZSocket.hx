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
import org.zeromq.ZMQSocket;
import org.zeromq.ZSocket;
import org.zeromq.ZContext;

class TestZSocket extends BaseTest
{

    public function testCreateDestroySocket()
    {
        var ctx:ZContext = new ZContext();
        var s:ZMQSocket = ctx.createSocket(ZMQ_REQ);
        assertTrue (s != null);
        assertFalse(s.closed);
        assertEquals(1, ctx.sockets.length);
        
        var s1:ZMQSocket = ctx.createSocket(ZMQ_SUB);
        assertTrue(s1 != null);
        assertEquals(2, ctx.sockets.length);
        
        ctx.destroySocket(s1);
        assertEquals(1, ctx.sockets.length);
        var _s:ZMQSocket = ctx.sockets.first();
        assertTrue(ZSocket.isType(_s, ZMQ_REQ));
    }
    
    public function testBindConnect() {
        var ctx:ZContext = new ZContext();
        var writer:ZMQSocket = ctx.createSocket(ZMQ_PUSH);
        var reader:ZMQSocket = ctx.createSocket(ZMQ_PULL);

        assertEquals(5560, ZSocket.bindEndpoint(writer, "tcp", "*", "5560"));
        ZSocket.connectEndpoint(reader, "tcp", "localhost", "5560");
        
        writer.sendMsg(Bytes.ofString("HELLO"));
        
        var b = reader.recvMsg();
        
        assertTrue(b != null);
        assertEquals("HELLO", b.toString());
        
        var p:Int = ZSocket.bindEndpoint(writer, "tcp", "*", "*");
        assertTrue(p >= ZSocket.DYNFROM && p <= ZSocket.DYNTO);
        
        ctx.destroy();
        
    }
    
}