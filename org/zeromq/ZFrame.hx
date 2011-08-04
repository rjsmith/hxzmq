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

package org.zeromq;

import haxe.io.Bytes;
import neko.Lib;
import org.zeromq.ZMQ;


/**
 * <p>
 * The ZFrame class provides methods to send and receive single message
 * frames across 0MQ sockets. A 'frame' corresponds to one underlying zmq_msg_t in the libzmq code.
 * When you read a frame from a socket, the more() method indicates if the frame is part of an 
 * unfinished multipart message.  The send() method normally destroys the frame, but with the ZFRAME_REUSE flag, you can send
 * the same frame many times. Frames are binary, and this class has no special support for text data.
 * </p>
 * <p>
 * Based on <a href="http://github.com/zeromq/czmq/blob/master/src/zframe.c">zframe.c</a> in czmq
 * </p>
 */
class ZFrame 
{

    public static inline var ZFRAME_MORE:Int = 1;
    public static inline var ZFRAME_REUSE:Int = 2;
    
    /** More flag, from last frame read */
    public var more(default, null):Bool;
    
    /** Message blob for frame */
    public var data(default,null):Bytes;
    
    /**
     * Constructor.
     * Copies message data into zframe object
     * @param	data
     */
    public function new(?data:Bytes) 
    {
        if (data != null) {
            this.data = Bytes.alloc(data.length);
            this.data.blit(0, data, 0, data.length);
        } 
    }
    
    /**
     * Destructor
     */
    public function destroy() {
        if (hasData()) {
            data = null;
        }
    }
    
    private function recv(socket:ZMQSocket):Bytes {
        if (socket == null) {
            throw new ZMQException(EINVAL);
        }
        try {
            data = socket.recvMsg();  
        } catch (e:ZMQException) {
            if (ZMQ.isInterrupted()) {
                destroy();
                return null;
            }
            Lib.rethrow(e);  // Propagate other exception
        }
        more = socket.hasReceiveMore();
        return data;
    }
    
    private function recvNoWait(socket:ZMQSocket):Bytes {
        if (socket == null) {
            throw new ZMQException(EINVAL);
        }
        try {
            data = socket.recvMsg(DONTWAIT);  
        } catch (e:ZMQException) {
            if (ZMQ.isInterrupted()) {
                destroy();
                return null;
            }
            Lib.rethrow(e);  // Propagate other exception
        }
        more = socket.hasReceiveMore();
        return data;
    }
    
    /**
     * Sends frame to socket, destroy after sending unless ZFRAME_REUSE is set
     * @param	socket
     * @param	flags
     */
    public function send(socket:ZMQSocket, ?flags:Int = 0) {
        if (socket == null || !hasData()) {
            throw new ZMQException(EINVAL);
        }
        socket.sendMsg(data, { if ((flags & ZFRAME_MORE)>0) SNDMORE else null; } );
       
        if ((flags & ZFRAME_REUSE) == 0) {
            destroy();
        }
    }
    
    /**
     * Returns byte size of frame, if set, else 0
     * @return
     */
    public inline function size():Int {
        return {
            if (hasData()) data.length else 0;
        }
    }
    
    /**
     * Creates a new frame that duplicates an existing frame
     * @return  A duplicates ZFrame object
     */
    public function duplicate():ZFrame {
        return new ZFrame(this.data);
    }
    
    /**
     * Returns true if both frames have identical size and data
     * @param	other
     * @return
     */
    public function equals(other:ZFrame):Bool {
        if (other == null) return false;
        
        if (size() == other.size()) {
            if (hasData() && other.data != null) {
                return data.compare(other.data) == 0;    
            }
            
        }
        return false;
    }
    
    /**
     * Set new contents for frame
     * @param	data    New data bytes for this frame
     */
    public function reset(data:Bytes) {
        if (data == null) {
            throw new ZMQException(EINVAL);          
        }
        this.data = data;
    }
    
    /**
     * Return frame data encoded as printable hex string
     * @return
     */
    public function strhex():String {
        
        var hex_char:String = "0123456789ABCDEF";
        
        var hexStr:StringBuf = new StringBuf();
        for (nbr in 0 ... data.length) {
            var b = data.get(nbr);
            hexStr.add(hex_char.charAt(b >> 4));
            hexStr.add(hex_char.charAt(b & 15));
        }
        return hexStr.toString();
    }
    
    /**
     * Returns true if frame body is equivalent to given string
     * @param	str
     * @return  true if matches, else false
     */
    public function streq(str:String):Bool {
        if (!hasData()) return false;
        return this.data.toString() == str;
    }
    
    /**
     * Convenience method to ascertain if this frame contains some message data
     * @return
     */
    public function hasData():Bool {
        var ret:Bool = data != null;
        return ret;
    }
    
    /**
     * Returns string representation of frame's data bytes
     * @return
     */
    public function toString():String {
        if (!hasData()) return null;
		
		var buf:StringBuf = new StringBuf();
		buf.add("[" + StringTools.lpad(Std.string(size()), "0", 3) + "] ");
		// Dump message as text or binary
		var isText = true;
		for (i in 0...data.length) {
			if (data.get(i) < 32 || data.get(i) > 127) isText = false; 
		}
		if (isText)
			buf.add(data.toString()) ;
		else
			buf.add(strhex());
			
		
        return buf.toString();
    }
    
    /**
     * Receives single frame from socket, returns the received frame object, or null if the recv
     * was interrupted. Does a blocking recv, if you want to not block then use
     * recvFrameNoWait()
     * 
     * @param	socket      Socket to read from
     * @return  received frame, else null
     */
    public static function recvFrame(socket:ZMQSocket):ZFrame {
        var f:ZFrame = new ZFrame();
        return {
			if (f.recv(socket) != null) 
				f;
			else
				null;
		}
    }
    
    /**
     * Receive a new frame off the socket, Returns newly-allocated frame, or
     * null if there was no input waiting, or if the read was interrupted.
     * @param	socket
     * @return  received frame, else null
     */
    public static function recvFrameNoWait(socket:ZMQSocket):ZFrame {
        var f:ZFrame = new ZFrame();
        f.recvNoWait(socket);
        return f;
    }
	
	/**
	 * Creates a new ZFrame object from a given string.
	 * 
	 * Can be used in combination with send method for a one-line command:
     * <pre>
	 * import org.zeromq.ZFrame;
	 * using  org.zeromq.ZFrame;
	 * ...
	 * ZFrame.newStringFrame("Hello".send(mySocket));
	 * var str = "World";
	 * str.newStringFrame().send(mySocket);
	 * </pre>
	 */
	public static function newStringFrame(str:String):ZFrame {
		return new ZFrame(Bytes.ofString(str));
	}
}