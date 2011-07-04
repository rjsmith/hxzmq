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
import neko.FileSystem;
import neko.io.File;
import org.zeromq.ZContext;
import org.zeromq.ZFrame;
import org.zeromq.ZMsg;
import org.zeromq.ZMQ;

class TestZMsg extends BaseTest 
{

    public function testSingleFrameMessages() {
        
        var ctx:ZContext = new ZContext();
        
        var output:ZMQSocket = ZSocket.create(ctx, ZMQ_PAIR);
        ZSocket.bind(output, "inproc", "zmsg.test");
        var input:ZMQSocket = ZSocket.create(ctx, ZMQ_PAIR);
        ZSocket.connect(input, "inproc", "zmsg.test");
        
        // Test send and receive of a single ZMsg
        var msg:ZMsg = new ZMsg();
        var frame:ZFrame = new ZFrame(Bytes.ofString("Hello"));
        msg.push(frame);
        assertEquals(1, msg.size());
        assertEquals(5, msg.contentSize());
        msg.send(output);
        assertTrue(msg.isEmpty());
        
        msg = ZMsg.recvMsg(input);
        assertTrue(msg != null);
        assertEquals(1, msg.size());
        assertEquals(5, msg.contentSize());
        msg.destroy();
       
        ctx.destroy();
    }
    
    public function testMultiPart() {
        var ctx:ZContext = new ZContext();
        
        var output:ZMQSocket = ZSocket.create(ctx, ZMQ_PAIR);
        ZSocket.bind(output, "inproc", "zmsg.test2");
        var input:ZMQSocket = ZSocket.create(ctx, ZMQ_PAIR);
        ZSocket.connect(input, "inproc", "zmsg.test2");

        var msg:ZMsg = new ZMsg();
        for (i in 0 ... 10) {
            msg.addString("Frame" + i);
        }
        var copy:ZMsg = msg.duplicate();
        copy.send(output);
        msg.send(output);
        
        copy = ZMsg.recvMsg(input);
        assertTrue(copy != null);
        assertEquals(10, copy.size());
        assertEquals(60, copy.contentSize());
        copy.destroy();
        
        msg = ZMsg.recvMsg(input);
        assertTrue(msg != null);
        assertEquals(10, msg.size());
        assertEquals(60, msg.contentSize());
        msg.destroy();
        
        ctx.destroy();
    }
    
    public function testMessageFrameManipulation() {
        var msg:ZMsg = new ZMsg();
        for (i in 0 ... 10) {
            msg.addString("Frame" + i);
        }
        
        // Remove all frames apart from first and last ones
        for (i in 0 ... 8) {
            var iter = msg.iterator();
            iter.next();    //skip first frame
            var f = iter.next();
            msg.remove(f);
            f.destroy();
        }
        
        assertEquals(2, msg.size());
        assertEquals(12, msg.contentSize());
        assertEquals("Frame0", msg.first().data.toString());
        assertEquals("Frame9", msg.last().data.toString());
        
        var f = new ZFrame(Bytes.ofString("Address"));
        msg.push(f);
        assertEquals(3, msg.size());
        assertEquals("Address", msg.first().data.toString());
        msg.addString("Body");
        assertEquals(4, msg.size());
        var frame0 = msg.popString();
        assertEquals("Address", frame0);
        var filteredMsg:ZMsg = msg.filter(
            function(f:ZFrame):Bool {
            return (StringTools.startsWith(f.data.toString(), "Frame")); } );
        assertEquals(2, filteredMsg.size());  
        filteredMsg.destroy();
        
        msg.destroy();
        
    }
    
    public function testEmptyMessage() {
        var msg:ZMsg = new ZMsg();
        assertEquals(0, msg.size());
        assertTrue(msg.first() == null);
        assertTrue(msg.last() == null);
        assertTrue(msg.isEmpty());
        assertTrue(msg.pop() == null);
        msg.destroy();
    }
    
    public function testReadWriteFile() {
        var msg:ZMsg = new ZMsg();
        for (i in 0 ... 10) {
            msg.addString("Frame" + i);
        }
        
        // Save msg to a file
        var outputStream = File.write("zmsg.test", true);
        assertTrue(ZMsg.save(msg, outputStream));
        outputStream.close();
        
        // Read msg out of file
        var inputStream = File.read("zmsg.test", true);
        msg = ZMsg.load(inputStream);
        inputStream.close();
        FileSystem.deleteFile("zmsg.test");
        
        assertEquals(10, msg.size());
        assertEquals(60, msg.contentSize());
        
        msg.destroy();
        
    }
}