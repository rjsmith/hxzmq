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

import neko.io.File;
import neko.io.FileInput;
import neko.Lib;
import neko.Sys;

import org.zeromq.guide.HelloWorldClient;
import org.zeromq.guide.HelloWorldServer;
import org.zeromq.guide.WUClient;
import org.zeromq.guide.WUServer;
import org.zeromq.guide.TaskVent;
import org.zeromq.guide.TaskWork;
import org.zeromq.guide.TaskSink;
import org.zeromq.guide.Interrupt;

/**
 * Main class that allows any of the implemented Haxe guide programs to run
 */
class Run 
{

	public static function main() 
	{
		var selection:Int;
		
		Lib.println("** HaXe ZeroMQ Guide program launcher **");
		
		if (Sys.args().length > 0) {
			selection = Std.parseInt(Sys.args()[0]);
		} else {
			Lib.println("");
			Lib.println("Programs:");
			
			Lib.println("1. HelloWorldClient");
			Lib.println("2. HelloWorldServer");
			Lib.println("");
			Lib.println("3. WUClient");
			Lib.println("4. WUServer");
			Lib.println("");
			Lib.println("5. TaskVent");
			Lib.println("6. TaskWork");
			Lib.println("7. TaskSink");
			Lib.println("");
			Lib.println("11. Interrupt (** Doesn't work on Windows!)");
			Lib.println("");
			Lib.println("12. MTServer");
			
			do {
				Lib.print("Type number followed by Enter key, or q to quit: ");
				var f:FileInput = File.stdin();
				var str:String = f.readLine();
		
				if (str.toLowerCase() == "q") {
					return;
				}
				
				selection = Std.parseInt(str);
			} while (selection == null);
		}
		
		switch (selection) {
			case 1:
				HelloWorldClient.main();
			case 2:
				HelloWorldServer.main();
			case 3:
				WUClient.main();
			case 4:
				WUServer.main();
			case 5:
				TaskVent.main();
			case 6:
				TaskWork.main();
			case 7:
				TaskSink.main();
			case 11:
				Interrupt.main();
			case 12:
				MTServer.main();
			default:
			Lib.println ("Unknown program number ... exiting");
		}
	}
	
}
