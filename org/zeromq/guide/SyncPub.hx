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
 * Synchronised publisher
 * 
 * See: http://zguide.zeromq.org/page:all#Node-Coordination
 * 
 * Use with SyncSub.hx
 */
class SyncPub 
{
    static inline var SUBSCRIBERS_EXPECTED = 10;
    
    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
        Lib.println("** SyncPub (see: http://zguide.zeromq.org/page:all#Node-Coordination)");
        
        // Socket to talk to clients
        var publisher:ZMQSocket = context.socket(ZMQ_PUB);
        publisher.bind("tcp://*:5561");
        
        // Socket to receive signals
        var syncService:ZMQSocket = context.socket(ZMQ_REP);
        syncService.bind("tcp://*:5562");
        
        // get synchronisation from subscribers
        var subscribers = 0;
        while (subscribers < SUBSCRIBERS_EXPECTED) {
            // wait for synchronisation request
            var msgBytes = syncService.recvMsg();
            
            // send synchronisation reply
            syncService.sendMsg(Bytes.ofString(""));
            subscribers++;
        }
        
        // Now broadcast exactly 1m updates followed by END
        for (update_nbr in 0 ... 1000000) {
            publisher.sendMsg(Bytes.ofString("Rhubarb"));
        }
        publisher.sendMsg(Bytes.ofString("END"));
        
        publisher.close();
        syncService.close();
        context.term();
    }
}