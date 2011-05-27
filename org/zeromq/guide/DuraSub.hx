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
 * Durable subscriber
 * 
 * See: http://zguide.zeromq.org/page:all#-Semi-Durable-Subscribers-and-High-Water-Marks
 * 
 * Use with DuraPub.hx and DuraPub2.hx
 */
class DuraSub 
{

    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
        
        Lib.println("** DuraSub (see: http://zguide.zeromq.org/page:all#-Semi-Durable-Subscribers-and-High-Water-Marks)");
        
        var subscriber:ZMQSocket = context.socket(ZMQ_SUB);
        subscriber.setsockopt(ZMQ_IDENTITY, Bytes.ofString("Hello"));
        subscriber.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString(""));
        subscriber.connect("tcp://127.0.0.1:5565");
        
        // Synschronise with publisher
        var sync:ZMQSocket = context.socket(ZMQ_PUSH);
        sync.connect("tcp://127.0.0.1:5564");
        sync.sendMsg(Bytes.ofString(""));
        
        // Get updates, exit when told to do so
        while (true) {
            var msgString:String = subscriber.recvMsg().toString();
            Lib.println(msgString + "\n");
            if (msgString == "END") {
                break;
            }
        }
        sync.close();
        subscriber.close();
        context.term();
    }
}