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
#if !php
import neko.vm.Thread;
#end
import neko.Lib;

import org.zeromq.ZMQ;
import org.zeromq.ZMQContext;
import org.zeromq.ZMQSocket;

/**
 * Multi-threaded relay in haXe
 * 
 */
class MTRelay 
{
    
    static function step1() {
        var context:ZMQContext = ZMQContext.instance();
        
        // Connect to step2 and tell it we are ready
        var xmitter:ZMQSocket = context.socket(ZMQ_PAIR);
#if (neko || cpp)        
        xmitter.connect("inproc://step2");
#elseif php
        xmitter.connect("ipc://step2.ipc");
#end        
        xmitter.sendMsg(Bytes.ofString("READY"));
        xmitter.close();
    }
    
    static function step2() {
        var context:ZMQContext = ZMQContext.instance();
        
        // Bind inproc socket before starting step 1
        var receiver:ZMQSocket = context.socket(ZMQ_PAIR);
#if (neko || cpp)        
        receiver.bind("inproc://step2");
        Thread.create(step1);
#elseif php
        receiver.bind("ipc://step2.ipc");
        untyped __php__('
            $pid = pcntl_fork();
            if($pid == 0) {
                step1();
                exit();
            }');
#end            
        // Wait for signal and pass it on
        var msgBytes = receiver.recvMsg();
        receiver.close();
        
        // Connect to step3 and tell it we are ready
        var xmitter:ZMQSocket = context.socket(ZMQ_PAIR);
#if (neko || cpp)        
        xmitter.connect("inproc://step3");
#elseif php
        xmitter.connect("ipc://step3.ipc");
#end        
        xmitter.sendMsg(Bytes.ofString("READY"));
        xmitter.close();
    }
    
    public static function main() {
        var context:ZMQContext = ZMQContext.instance();
        
		Lib.println ("** MTRelay (see: http://zguide.zeromq.org/page:all#Signaling-between-Threads)");

        // This main thread represents Step 3
        
        // Bind to inproc: endpoint then start upstream thread
        var receiver:ZMQSocket = context.socket(ZMQ_PAIR);
#if (neko || cpp)        
        receiver.bind("inproc://step3");
 
        // Step2 relays the signal to step 3
        Thread.create(step2);
#elseif php
        // Use child processes instead of Threads
        receiver.bind("ipc://step3.ipc");
        // Step2 relays the signal to step 3
        untyped __php__('
            $pid = pcntl_fork();
            if ($pid == 0) {
                step2();
                exit();
            }');
        
#end        
        // Wait for signal
        var msgBytes = receiver.recvMsg();
        receiver.close();
        
        trace ("Test successful!");
        context.term();
    }
}