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
import neko.Lib;
import haxe.io.Bytes;
import neko.Sys;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

/**
 * Publisher for durable subscriber
 * 
 * See: http://zguide.zeromq.org/page:all#-Semi-Durable-Subscribers-and-High-Water-Marks
 * 
 * Use with DuraSub.hx
 */
class DuraPub 
{

    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
        
        Lib.println("** DuraPub (see: http://zguide.zeromq.org/page:all#-Semi-Durable-Subscribers-and-High-Water-Marks)");
        
        // Subscriber tells us when it is ready here
        var sync:ZMQSocket = context.socket(ZMQ_PULL);
        sync.bind("tcp://*:5564");
        
        // We send updates via this socket
        var publisher:ZMQSocket = context.socket(ZMQ_PUB);
        
        // Uncomment next line to see effect of adding a high water mark to the publisher
        // publisher.setsockopt(ZMQ_HWM, { hi:0, lo: 2 } );   // Set HWM to 2
        
        publisher.bind("tcp://*:5565");
        
        // Wait for synchronisation request
        sync.recvMsg();
        
        for (update_nbr in 0 ... 10) {
            var str = "Update " + update_nbr;
            Lib.println(str);
            publisher.sendMsg(Bytes.ofString(str));
            Sys.sleep(1.0);
        }
        publisher.sendMsg(Bytes.ofString("END"));
        
        sync.close();
        publisher.close();
        context.term();
    }
}