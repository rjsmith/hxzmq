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

import org.zeromq.ZMQ;
import org.zeromq.ZMQSocket;

/**
 * <p>
 * ZContext provides a higher-level zeroMQ context management class.
 * It is inspired by the <a href="http://github.com/zeromq/czmq/blob/master/src/zctx.c">zctx.c</a> source code in the czmq project.
 * </p>
 * <p>
 * The ZContext class wraps haXe ZMQContext objects, which in turn wrap native 0MQ contexts.
 * It manages open sockets in the context and automatically closes these before terminating the context. 
 * It provides a simple way to set the linger timeout on sockets, and configure contexts for number of I/O threads. 
 * Sets-up signal (interrrupt) handling for the process.
 * </p>
 * <p>
 * The ZContext class has these main features:<br />
 * 1. Tracks all open sockets and automatically closes them before calling zmq_term(). This avoids an infinite wait on open sockets.<br />
 * 2. Automatically configures sockets with a ZMQ_LINGER timeout you can define, and which defaults to zero. The default behaviour of ZContext is therefore like 0MQ/2.0, immediate termination with loss of any pending messages. You can set any linger timeout you like by calling the zctx_set_linger() method.<br />
 * 3. Moves the iothreads configuration to a separate method, so that default usage is 1 I/O thread. Lets you configure this value.<br />
 * 4. Sets up signal (SIGINT and SIGTERM) handling so that blocking calls such as zmq_recv() and zmq_poll() will return when the user presses Ctrl-C.<br />
 * 
 * </p>
 */
class ZContext 
{

    /** Reference to underlying ZMQContext object */
    public var context(default, null):ZMQContext;
    
    /** List of sockets managed by this ZContext */
    public var sockets(default, null):List<ZMQSocket>;
    
    /** Number of io threads allocated to this context, default 1 */
    public var ioThreads(default, default):Int;
    
    /** Linger timeout, default 0 */
    public var linger(default, default):Int;
    
    /** Indicates if context object owned by main thread */
    public var main(default, default):Bool;
    
    /**
     * Constructor
     */
    public function new() 
    {
        context = null;
        sockets = new List<ZMQSocket>();
        ioThreads = 1;
        linger = 0;
        main = true;
        
        // Set up signal handling
#if !php        
        ZMQ.catchSignals();
#end        
    }
    
    /**
     * Destructor. Call this to gracefully close context and managed sockets
     */
    public function destroy()
    {
        // TODO: Iterate round sockets
        for (s in sockets) {
            destroySocket(s);
        }
        sockets.clear();
        
        // Only terminate context if we are on the main thread
        if (main && context != null) {
            context.term();
        }
        
    }
    
    /**
     * Creates a new managed socket within this ZContext context.
       * Use this to get automatic management of the socket at shutdown
     * @param	type
     * @return
     */
    public function createSocket(type:SocketType):ZMQSocket {
        if (context == null) {
            context = new ZMQContext(ioThreads);
        }
        if (!context.closed) {
            // Create and register socket
            var socket:ZMQSocket = context.socket(type);
            sockets.add(socket);
            return socket;
        } else {
            throw new ZMQException(ENOTSUP);
        }
    }
    
    /**
     * Destroys managed socket within this context.
     * @param	s   Socket to remove
     */
    public function destroySocket(s:ZMQSocket) {
        if (s == null) {
            throw new ZMQException(ENOTSUP);
        }
        s.setsockopt(ZMQ_LINGER, linger);
        s.close();
        sockets.remove(s);
    }
    
    /**
     * Creates new shadow context.
     * Shares same underlying ZMQContext but has own list of managed sockets, io thread count etc.
     * @param   ctx     Original ZContext to create shadow of.
     * @return  New ZContext object
     */
    public static function shadow(ctx: ZContext):ZContext {
        
        var shadow:ZContext = new ZContext();
        shadow.context = ctx.context;
        return shadow;
    }
    
    
}