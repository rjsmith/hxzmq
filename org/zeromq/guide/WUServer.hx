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
import neko.Random;
import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

/**
 * Weather update server in Haxe
 * Binds PUB socket to tcp://*:5556
 * Publishes random weather updates
 * 
 * See: http://zguide.zeromq.org/page:all#Getting-the-Message-Out
 * 
 * Use with WUClient.hx
 */
class WUServer 
{

	public static function main() {
		var context:ZMQContext = ZMQContext.instance();
		
		Lib.println("** WUServer (see: http://zguide.zeromq.org/page:all#Getting-the-Message-Out)");

		var publisher:ZMQSocket = context.socket(ZMQ_PUB);
		publisher.bind("tcp://127.0.0.1:5556");
		
		while (true) {
			// Get values that will fool the boss
			var zipcode, temperature, relhumidity;
			zipcode = Std.random(100000) + 1;
			temperature = Std.random(215) - 80 + 1;
			relhumidity = Std.random(50) + 10 + 1;
			
			// Send message to all subscribers
			var update:String = zipcode + " " + temperature + " " + relhumidity;
			publisher.sendMsg(Bytes.ofString(update));
		}
	}
}