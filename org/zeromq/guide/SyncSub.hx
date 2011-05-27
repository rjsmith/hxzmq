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
 * Synchronised subscriber
 * 
 * See: http://zguide.zeromq.org/page:all#Node-Coordination 
 * 
 * Use with SyncPub.hx
 */
class SyncSub 
{

    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
        
        Lib.println("** SyncSub (see: http://zguide.zeromq.org/page:all#Node-Coordination)");
        
        // First connect our subscriber socket
        var subscriber:ZMQSocket = context.socket(ZMQ_SUB);
        subscriber.connect("tcp://127.0.0.1:5561");
        subscriber.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString(""));
        
        // 0MQ is so fast, we need to wait a little while
        Sys.sleep(1.0);
        
        // Second, synchronise with publisher
        var syncClient:ZMQSocket = context.socket(ZMQ_REQ);
        syncClient.connect("tcp://127.0.0.1:5562");
        
        // Send a synchronisation request
        syncClient.sendMsg(Bytes.ofString(""));
        
        // Wait for a synchronisation reply
        var msgBytes:Bytes = syncClient.recvMsg();
        
        // Third, get our updates and report how many we got
        var update_nbr = 0;
        while (true) {
            msgBytes = subscriber.recvMsg();
            if (msgBytes.toString() == "END") {
                break;
            }
            msgBytes = null;
            update_nbr++;
        }
        Lib.println("Received " + update_nbr + " updates\n");
        
        subscriber.close();
        syncClient.close();
        context.term();
    }
}