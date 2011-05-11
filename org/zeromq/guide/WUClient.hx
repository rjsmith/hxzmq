/**
 * (c) $(CopyrightDate) Richard J Smith
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
import neko.Sys;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQException;
import org.zeromq.ZMQSocket;

/**
 * Weather update client in Haxe
 * Connects SUB socket to tcp://localhost:5556
 * Collects weather updates and finds average temp in zipcode
 * 
 * Use optional argument to specify zip code (in range 1 to 100000)
 * 
 * See: http://zguide.zeromq.org/page:all#Getting-the-Message-Out
 */
class WUClient 
{

	public static function main() {
		var context:ZMQContext = ZMQContext.instance();
		
		Lib.println("** WUClient (see: http://zguide.zeromq.org/page:all#Getting-the-Message-Out)");
		
		// Socket to talk to server
		trace ("Collecting updates from weather server...");
		var subscriber:ZMQSocket = context.socket(ZMQ_SUB);
		subscriber.setsockopt(ZMQ_LINGER, 0);	 // Don't block when closing socket at end
		
		subscriber.connect("tcp://localhost:5556");
		
		// Subscribe to zipcode, default in NYC, 10001
		var filter:String = 
			if (Sys.args().length > 0) {
				Sys.args()[0];
			} else {
				"10001";
			};
				
		try {
			subscriber.setsockopt(ZMQ_SUBSCRIBE, Bytes.ofString(filter));
		} catch (e:ZMQException) {
			trace (e.str());
		}
		
		// Process 100 updates
		var update_nbr = 0;
		var total_temp:Int = 0;
		for (update_nbr in 0...100) {
			var msg:Bytes = subscriber.recvMsg();
			trace (update_nbr+ ". Received: " + msg.toString());
			
			var zipcode, temperature, relhumidity;
			
			var sscanf:Array<String> = msg.toString().split(" ");
			zipcode = sscanf[0];
			temperature = sscanf[1];
			relhumidity = sscanf[2];
			total_temp += Std.parseInt(temperature);
			
		}
		trace ("Average temperature for zipcode " + filter + " was " + total_temp / 100);
		
		// Close gracefully
		subscriber.close();
		context.term();
	}
}