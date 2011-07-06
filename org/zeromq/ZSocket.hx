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
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

/**
 * <p>
 * ZSocket provides higher-level ZMQSocket socket helper static methods.
 * </p>
 * <p>
 * <pre>
 * import org.zeromq.ZMQ;
 * using org.zeromq.ZSocket;
 * ...
 * var output = ctx.createSocket(ZMQ_PUSH);
 * var input = ctx.createSocket(ZMQ_PULL);
 * 
 * // Bind to a tcp port on localhost
 * var port = output.bind("tcp", "*", "5560");
 * 
 * // Connect
 * input.connect("tcp", "localhost", "5560");
 * </pre>
 * 
 * <p>
 * Based on the <a href="http://github.com/zeromq/czmq/blob/master/src/zsocket.c">zsocket.c</a> source code in the czmq project.
 * </p>
 * 
 */

class ZSocket 
{

    /** This port range is defined by IANA for dynamic or private ports.
     * Used when choosing port for dynamic binding.
     */
    public static inline var DYNFROM:Int = 0xc000;
    public static inline var DYNTO:Int = 0xffff;
    
    
    /**
     * Tests type of socket
     * @param	socket  Socket to test
     * @param	type    SocketType enum to test for
     * @return  true if socket is of given type, else false, else null if could not determine socket type
     */
    public static function isType(socket:ZMQSocket, type:SocketType):Bool {
        if (socket == null) {
            throw new ZMQException(EINVAL);
        }
        var t:Int = socket.getsockopt(ZMQ_TYPE);
        return {
            if (t != null) {
                ZMQ.socketTypeNo(type) == t;
            } else {
                null;
            }
        }
    }
   
    /**
     * Bind a socket to an endpoint given by a specified protoype, interface address and port number
     * If the port is specified as null, or not specified, binds to any free port from DYNFROM to DYNTO
     * and returns the actual port number used. Otherwise asserts that the bind succeeded with the 
     * specified port number. Always return the port number if successful.
     * @param	socket      ZMQSocket to bind to
     * @param	protocol    Network protocol "tcp", "inproc" etc
     * @param	interf      Bind address "foo.com", "127.0.0.3"
     * @param	port        (optional) Port number
     * @return  Port number if bind successful, else -1
     */
    public static function bindEndpoint(socket:ZMQSocket, protocol:String, interf:String, ?port:String):Int {
        if (socket == null || protocol == null || interf == null) {
            throw new ZMQException(EINVAL);
        }
        var endpoint:String = protocol + "://" + interf;
        var rc:Int;
        if (port == "*") {
            rc = -1;
            for (p in DYNFROM ... DYNTO) {
                try {
                    socket.bind(endpoint + ":" + p);
                    return p;
                } catch (e:ZMQException) {
                    // Ignore error. Go round and try another port
                }
            }
        } else {
            if (port != null)
                endpoint += ":" + port;
            socket.bind(endpoint);
            rc = Std.parseInt(port);
        }
        return rc;
    }
    
    /**
     * Connects a socket to a defined endpoint
     * 
     * @param	socket      ZMQSocket to bind to
     * @param	protocol    Network protocol "tcp", "inproc" etc
     * @param	interf      Bind address "foo.com", "127.0.0.3"
     * @param	port        Port number
     */
    public static function connectEndpoint(socket:ZMQSocket, protocol:String, interf:String, ?port:String) {
        if (socket == null || protocol == null || interf == null) {
            throw new ZMQException(EINVAL);
        }
        var endpoint:String = protocol + "://" + interf;
        if (port != null) endpoint += ":" + port;
        socket.connect(endpoint);
    }
    
}