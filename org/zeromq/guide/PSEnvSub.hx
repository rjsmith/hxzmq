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
import neko.Lib;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

/**
 * Pubsub envelope subscriber
 * 
 * See: http://zguide.zeromq.org/page:all#Pub-sub-Message-Envelopes
 * 
 * Use with PSEnvPub
 */
class PSEnvSub 
{

    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
        
        Lib.println("** PSEnvSub (see: http://zguide.zeromq.org/page:all#Pub-sub-Message-Envelopes)");
        
        var subscriber:ZMQSocket = context.socket(ZMQ_SUB);
        subscriber.connect("tcp://127.0.0.1:5563");
        subscriber.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString("B"));
        
        while (true) {
            var msgAddress:Bytes = subscriber.recvMsg();
            // Read message contents
            var msgContent:Bytes = subscriber.recvMsg();
            trace (msgAddress.toString() + " " + msgContent.toString() + "\n");
        }
        // We never get here but clean up anyway
        subscriber.close();
        context.term();
    }
}