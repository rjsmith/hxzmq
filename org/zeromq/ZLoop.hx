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

import haxe.Log;
import neko.Lib;
import neko.Sys;
import org.zeromq.ZMQ;
import org.zeromq.ZMQSocket;
import org.zeromq.ZMQPoller;

typedef PollItemT = {
    socket:ZMQSocket,
    event:Int
};

typedef PollerT = {
    pollItem:PollItemT,
    handler: ZMQSocket -> Int,
};

typedef TimerT = {
    delay:Float,    // Number of milliseconds to delay before triggering timed event
    times:Int,      // Number of times to repeat timed event, separated by delay
    handler:Void->Int,
    when:Float     // Number of milliseconds since 1 Jan 1970 to trigger timer event
};

/**
 * <p>
 * The ZLoop class provides an event-driven reactor pattern. The reactor handles socket readers not writers,
 * and once-off or repeated timers.  its resolution is 1 msec. It uses a tickless timer to reduce CPU interrupts in
 * inactive processes.
 * </p>
 * <p>
 * Note that at present, it only supports 0MQ sockets; polling of haXe Socket objects is not supported. 
 * </p>
 * <p>
 * Based on <a href="http://github.com/zeromq/czmq/blob/master/src/zloop.c">zloop.c</a> in czmq
 * </p>
 */
class ZLoop 
{

    /** Turns on verbose trace logging */
    public var verbose:Bool;
    
    /** List of registered pollers */
    private var pollers:List<PollerT>;
    
    /** List of registered timers */
    private var timers:List<TimerT>;
    
    /** List of timers to kill */
    private var zombies:List<TimerT>;
    
    /** Internal ZMQPoller object that holds the actual pollset used when querying socket state */
    private var poller:ZMQPoller;
    
    /** True if list of pollers and timers are different to pollset held within the poller object */
    private var dirty:Bool;
    
    /** Logger function used in verbose mode. Set during ZLoop construction */
    private var log:Dynamic->Void;
    
    /**
     * Constructor
     * @param logger    (Optional). Provide a logging function that accepts zloop trace log entries generated when verbose = true.
     */
    public function new(?logger:Dynamic->Void) 
    {
        pollers = new List<PollerT>();
        timers = new List<TimerT>();
        zombies = new List<TimerT>();
        poller = new ZMQPoller();
        verbose = false;
        if (logger != null) {
            log = logger;
        } else {
            log = Lib.println;
        }
    }
    
    /**
     * Destructor
     */
    public function destroy() {
        // Destroy list of pollers
        pollers.clear();
        
        // Destroy list of timers
        timers.clear();
        zombies.clear();
        poller.unregisterAllSockets();
        poller = null;
    }
    
    /**
     * Register a timer that expires after some delay and repeats some number of times. At each expiry, will call the handler.
     * To run a timer forever, use 0 times. Returns true if OK, false if there was an error
     * @param	delay       Number of milliseconds to delay event for
     * @param	times       Number of times to repeat, else 0 for forever
     * @param	handler     Handler function
     * @return  true if OK, else false
     */
    public function registerTimer(delay:Float, times:Int, handler:Void->Int):Bool {
        timers.push(ZLoop.newTimer(delay, times, handler));
        if (verbose)
            log("I: zloop: register timer delay=" + delay + " times=" + times);
        return true;    
    }
    
    /**
     * Register pollitem with the reactor. When the pollitem is ready, will call
     * the handler.  Returns true if OK, else false.
     * If you register a pollitem more than once, each instance will invoke its
     * corresponding handler.
     * @param	item        PollItem (socket & polled-for event)
     * @param	handler     Handler function, receives polled ZMQSocket object
     * @return  true if OK, else false
     */
    public function registerPoller(item:PollItemT, handler:ZMQSocket->Int):Bool {
        if (item == null || handler == null) {
            throw new ZMQException(EINVAL);
        }
        pollers.push(newPoller(item, handler));
        dirty = true;
        if (verbose) 
            log("I: zloop: register socket poller " + item.socket.type);
        return true;    
    }
    
    /**
     * Start the reactor. Takes control of the thread and returns when the 0MQ
     * context is terminated or the process is interrupted, or any event handler returns -1.
     * Event handlers may register new sockets and timers, and cancel sockets.
     * @return Returns 0 if interrupted, -1 if cancelled by a handler
     */
    public function start():Int {
        var rc:Int = 0;
        
        // Re-calculate all timers now
        var now:Float = Sys.time();
        for ( t in timers) {
            t.when = now + t.delay;
        }
        
        // Main reactor loop
        while (true) {
            if (dirty) {
               rebuildPollset();
            }
            try {
                rc = poller.poll(ticklessTimer() * 1000);
            } catch (e:ZMQException) {
#if !php                
                if (ZMQ.isInterrupted()) {
                    if (verbose)
                        log("I: zloop: main loop interrupted");
                    rc = 0;
                    break;
                }
#end                
                if (verbose)
                    log("E: zloop: " + e.toString());
                Lib.rethrow (e);
                
            } catch (e:Dynamic) {
                if (verbose)
                    log("E: zloop: " + e);
                Lib.rethrow(e);
            }
            if (rc == -1 #if !php ||  ZMQ.isInterrupted() #end ) {
               if (verbose)
                   log("I: zloop: interrupted");
               rc = 0;
               break;
            }
            // Handle any timers that have now expired
            for ( t in timers) {
                now = Date.now().getTime();
                if (now >= t.when && t.when != -1) {
                    if (verbose)
                        log("I: zloop: call timer handler");
                    rc = t.handler();
                    if (rc == -1)
                        break;  // Timer handler signalled break
                    if (--t.times == 0) {
                        timers.remove(t);
                    } else
                        t.when = t.delay + now;
                }
            }
            // Handle any pollers that are ready
            var item_nbr:Int = 0;
            for (p in pollers) {
                if (poller.pollin(++item_nbr)) {
                    if (verbose)
                        log("I: zloop: call socket handler");
                    rc = p.handler(p.pollItem.socket);
                    if (rc == -1) 
                        break;  // Poller handler signalled break
                }
            }
            
            if (rc == -1)
                break;
                    
        }
        
        return rc;
    }
    
    
    /**
     * Rebuilds pollset held within the poller object from list of registered pollers
     */
    private function rebuildPollset() {
        poller.unregisterAllSockets();
        for (p in pollers) {
            poller.registerSocket(p.pollItem.socket, p.pollItem.event);
        }
        dirty = false;
    }
    
    /**
     * Calculate timeout between now and next timed event
     * @return  Number of milliseconds between now and next timed event
     */
    private function ticklessTimer():Int {
        // Calculate next timer event time, up to 1 hour from now
        var now:Float = Sys.time();
        var tickless:Float = now + (1000 * 3600);
        for (t in timers) {
            if (t.when == null) {
                t.when = t.delay + now;
            }
            if (tickless > t.when) tickless = t.when;
        }
        var timeout:Int = Std.int(tickless - now);
        if (timeout < 0) timeout = 0;
        if (verbose) log("I: ZLoop: polling for " + timeout + " msec");
        
        return timeout;
    }
    
    /**
     * Creates a new Poller T anonymous object
     * @param	item
     * @param	handler
     * @return
     */
    private static function newPoller(item:PollItemT, handler:ZMQSocket->Int):PollerT {
        return {
            pollItem:item,
            handler:handler,
        }
    }
    
    /**
     * Creates a new TimerT anonymous object
     * @param	delay
     * @param	times
     * @param	handler
     * @return
     */
    private static function newTimer(delay:Float, times:Int, handler:Void->Int):TimerT {
        return {
            delay:delay,
            times:times,
            handler:handler,
            when:null     // Indicates a new timer
        }
    }
    
    
}