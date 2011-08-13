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
import neko.io.FileInput;
import neko.io.FileOutput;
import org.zeromq.ZMQ;
import org.zeromq.ZFrame;

/**
 * <p>The ZMsg class provides methods to send and receive multipart messages
 * across 0MQ sockets. This class provides a list-like container interface,
 * with methods to work with the overall container.  ZMsg messages are
 * composed of zero or more ZFrame objects.
 * </p>
 * <p>
 * <pre>
 * // Send a simple single-frame string message on a ZMQSocket "output" socket object
 * ZMsg.newStringMsg("Hello").send(output);
 * 
 * // Add several frames into one message
 * var msg:ZMsg = new ZMsg();
 * for (i in 0 ... 10) {
 *     msg.addString("Frame" + i);
 * }
 * msg.send(output);
 * 
 * // Receive message from ZMQSocket "input" socket object and iterate over frames
 * var receivedMessage = ZMsg.recvMsg(input);
 * for (f in receivedMessage) {
 *     // Do something with frame f (of type ZFrame)
 * }
 * </pre>
 * </p>
 * <p>
 * Based on <a href="http://github.com/zeromq/czmq/blob/master/src/zmsg.c">zmsg.c</a> in czmq
 * </p>
 */
class ZMsg 
{

    // Hold internal list of ZFrame objects
    private var frames:List<ZFrame>;
        
    /**
     * Constructor
     */
    public function new() {
        frames = new List<ZFrame>();
    }
    
    /**
     * Destructor.
     * Destroys all ZFrames stored in ZMsg
     */
    public function destroy() {
		if (frames == null)		// Handle usecase if destroy() is called repeatedly on same ZMsg object
			return;
        while (frames.length > 0) {
            var f:ZFrame = frames.pop();
            f.destroy();
        }
        frames = null;
    }
    
    /** Return number of frames in message */
    public function size():Int {
        if (frames != null) {
            return frames.length;
        } else {
            return 0;
        }
    }
    
    /**
     * Return number of bytes contained in all the frames in this message
     * @return
     */
    public function contentSize():Int {
        var size:Int = 0;
        if (frames != null) {
            for (f in frames) {
                size += f.size();
            }
        }
        return size;
    }
    /**
     * Add a ZFrame to end of list
     * @param	frame   ZFrame to add to list
     * @throws ZMQException if frame is null
     */
    public function add(frame:ZFrame) {
        if (frame == null) {
            throw new ZMQException(EINVAL);
        }
        frames.add(frame);
    }
    
	/**
	 * Push frame plus empty frame to front of message, before first frame.
	 * Message takes ownership of frame, will destroy it when message is sent.
	 */
	public function wrap(frame:ZFrame) {
		if (frame != null) {
			push(new ZFrame(Bytes.ofString("")));
			push(frame);
		}
	}
	
	/**
	 * Pop frame off front of message, caller now owns frame.
	 * If next frame is empty, pops and destroys that empty frame
	 * (e.g. useful when unwrapping ROUTER socket envelopes)
	 * @return	Unwrapped frame
	 */
	public function unwrap():ZFrame {
		if (size() == 0) {
			return null;
		} else {
			var f = pop();
			var empty:ZFrame = first();
			if (empty.hasData() && empty.size() == 0) {
				empty = pop();
				empty.destroy();
			}
			return f;
		}
	}
	
    /**
     * Removes an existing frame from the message.
     * Does not destroy the removed frame.
     * @param	frame   ZFrame to remove
     * @return  true if frame is found and removed, else false
     */
    public function remove(frame:ZFrame):Bool {
        if (frame == null) {
            throw new ZMQException(EINVAL);
        }
        return frames.remove(frame);
    }
    
    /**
     * Returns an iterator over the ZFrame list within the ZMsg
     * @return
     */
    public function iterator():Iterator<ZFrame> {
        if (frames != null) {
            return frames.iterator();
        } else
            return null;
    }
    
    /**
     * Returns a new ZMsg object containing only those ZFrames from this message
     * where f(x) is true
     * @param	f
     * @return  Filtered ZMsg object, else null if this message contains no frame list (ie has been destroyed)
     */
    public function filter(f: ZFrame -> Bool):ZMsg {
        if (frames != null) {
            var filteredFrames:List<ZFrame> = frames.filter(f);
            var filteredMsg:ZMsg = new ZMsg();
            for (frame in filteredFrames) {
                filteredMsg.add(frame);
            }
            return filteredMsg;
        } else
            return null;
    }
    
    /**
     * Returns last frame in message, else null if frame list is empty or invalid (destroyed)
     * @return
     */
    public function first():ZFrame {
        if (frames != null) {
            return frames.first();
        } else
            return null;
    }
    
    /**
     * returns True if the ZMsg has no frames, else false
     * @return
     */
    public function isEmpty():Bool {
        return (frames == null || size() == 0);
    }
    
    /**
     * Returns last frame in message, else null if frame list is empty or invalid (destroyed)
     * @return
     */
    public function last():ZFrame {
       if (frames != null) {
            return frames.last();
        } else
            return null;
    }
    
    /**
     * Removes first frame from message, if any. Returns frame or null.
     * Caller now owns frame and must destroy() it when finished with it.
     * @return
     */
    public function pop():ZFrame {
        if (frames != null) {
            return frames.pop();
        } else
            return null;
    }
    
    /**
     * Push frame to the front of the message, before all the other frames.
     * ZMsg object takes ownership of the frame, will destroy it when message is sent.
     * @param	frame
     */
    public function push(frame:ZFrame) {
        if (frame == null) {
            throw new ZMQException(EINVAL);
        }
        if (frames != null) {
            frames.push(frame);
        }
    }
    
    /**
     * Pushes string as new ZFrame at front of ZMsg frame list
     * @param	str
     */
    public function pushString(str:String) {
        if (frames == null) {
            frames = new List<ZFrame>();
        }
        frames.push(new ZFrame(Bytes.ofString(str)));
    }
    
    /**
     * Adds string as new ZFrame at end of ZMsg frame list
     * @param	str
     */
    public function addString(str:String) {
        if (frames == null) {
            frames = new List<ZFrame>();
        }
        frames.add(new ZFrame(Bytes.ofString(str)));
    }
   
    /**
     * Pop frame off top of message, returns as a String, else null if
     * no frames in message, or if popped frame has no data.
     * @return
     */
    public function popString():String {
        if (frames != null) {
            var f:ZFrame = frames.pop();
            if (f != null && f.hasData()) {
                var s = f.data.toString();
                f.destroy();
                return s;
            }
        }
        return null;
    }
    
    /**
     * Creates copy of this message, also copying all contained frames & their data
     * @return  Copied ZMsg object, or null if this message contains an invalid (destroyed) frame list.
     */
    public function duplicate():ZMsg {
        if (frames != null) {
            var msg:ZMsg = new ZMsg();
            for (f in frames) {
                msg.add(f.duplicate());
            }
            return msg;
        } else
            return null;
    }
    
    /**
     * Send message to socket, destroys after sending.  If the message has no
     * frames, sends nothing but destroys the message anyhow.
     * @param	socket
     */
    public function send(socket:ZMQSocket):Void {
        if (socket == null) {
            throw new ZMQException(EINVAL);
            return;
        }
        if (frames == null) {
            return;
        }
        var iter:Iterator<ZFrame> = iterator();
        var f:ZFrame = iter.next();
        while (f != null) {
            f.send(socket, { if (iter.hasNext()) ZFrame.ZFRAME_MORE else null; });
            f = iter.next();
        }
        destroy();
        return;
    }
    
	/**
	 * Returns msg contents as a readable string
	 * @return
	 */
	public function toString():String {
		var buf:StringBuf = new StringBuf();
		if (isEmpty()) {
			buf.add("empty");
		} else {
			buf.add("#frames:" + size());
			var frame_nbr = 0;
			for (f in frames) {
				buf.add(",#" + ++frame_nbr + ":[");
				buf.add(f.toString());
				buf.add("]");
			}
		}
		return buf.toString();
	}
	
    /**
     * Receives message from socket, returns ZMsg object or null if the
     * recv was interrupted. Does a blocking recv, if you want not to block then use
     * the ZLoop class or ZMQPoller to check for socket input before receiving.
     * @param	socket
     * @return
     */
    public static function recvMsg(socket:ZMQSocket):ZMsg {
        if (socket == null) {
            throw new ZMQException(EINVAL);
            return null;
        }
        var msg:ZMsg = null;
        
        while (true) {
            var f:ZFrame = ZFrame.recvFrame(socket);
            if (f == null) {
                // If receive failed or was interrupted
                if (msg != null) msg.destroy();
                break;
            }
			if (msg == null) msg = new ZMsg();
            msg.add(f);
            if (!f.more) {
                break;
            }
        }
        
        return msg;
    }
    
    /**
     * Simple method that adds a single supplied string to a new ZMsg, and returns the message object
     * @param	data
     * @return
     */
    public static function newStringMsg(data:String):ZMsg {
        var msg:ZMsg = new ZMsg();
        msg.addString(data);
        return msg;
    }
    
    /**
     * Save message to an open file, return true if OK, else false
     * 
     * Data saved as:
     * 4 bytes: number of frames
     * For every frame:
     *  4 bytes: byte size of frame
     *  + bytes: frame data bytes
     * 
     * @param	msg
     * @param	file
     * @return
     */
    public static function save(msg:ZMsg, file:FileOutput):Bool {
        if (file == null || msg == null) {
            throw new ZMQException(EINVAL);
            return false; 
        }
        try {
            // Write number of frames
            file.writeInt31(msg.size());
            if (msg.size() > 0) {
                for (f in msg.frames) {
                    // Write byte size of frame
                    file.writeInt31(f.size());
                    // Write frame byte data
                    file.prepare(f.size());
                    file.writeBytes(f.data, 0, f.size());
                }
            }
            return true;
        } catch (e:Dynamic) {
            return false;
        }
    }
    
    /**
     * Load / append a ZMsg from an open file.
     * Create a new message if null message provided.
     * 
     * @param	file
     * @param	?msg
     * @return
     */
    public static function load(file:FileInput, ?msg:ZMsg):ZMsg {
        if (file == null) {
            throw new ZMQException(EINVAL);
            return null;
        }
        var rcvMsg:ZMsg = {
            if (msg == null) 
                new ZMsg() 
            else
                msg;
        }

        var msgSize = file.readInt31();
        if (msgSize > 0) {
            var msg_nbr = 0;
            while (++msg_nbr <= msgSize) {
                var frameSize = file.readInt31();
                var f:ZFrame = new ZFrame(file.read(frameSize));
                rcvMsg.add(f);
                
            }
        }
        return rcvMsg;
        
    }
    
}