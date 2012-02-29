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

package org.zeromq;
import haxe.io.Bytes;
#if (neko || cpp)
import neko.vm.Thread;
#end
import org.zeromq.ZMQ;

/**
 * ZeroMQ Threading class
 * 
 * Creates neko / cpp Threads, or forks processes (PHP).
 * Using ZThread.fork provides the thread / process with a pre-configured ZMQ PAIR socket
 * for 2-way communication back to the parent.
 */
class ZThread 
{

	private static function attachedShim_fn(thread_fn:ZContext->ZMQSocket->Dynamic->Void, ctx:ZContext, pipe:ZMQSocket, args:Dynamic) {
		thread_fn(ctx, pipe, args);
		// Destroy any dangling sockets from attached thread
		ctx.destroy();
		return;
	}
	/**
	 * Create a detached thread (or forked process for php). A detached thread operates autonomously
	 * and is used to simulate a separate process. It gets no ctx or pipe socket
	 * @param	thread_fn
	 */
	public static function detach(thread_fn:Dynamic->Void, args:Dynamic) {
#if (neko || cpp)
		Thread.create(callback(thread_fn, args));
#elseif php
untyped __php__('
		$pid = pcntl_fork();
		if ($pid == 0) {
			// Running in child process
			thread_fn($args);
			exit();
		}');
#end
	}
	
	/**
	 * Creates an attached thread (or forked process, for php).
	 * An attached thread/process gets a ctx and a PAIR pipe
	 * back to its parent.  It must monitor its pipe, and exit
	 * if the pipe becomes unreadable.
	 * @param	ctx
	 * @param	thread_fn
	 * @param	args
	 * @return
	 */
	public static function attach(ctx:ZContext, thread_fn:ZContext->ZMQSocket->Dynamic->Void, args:Dynamic):ZMQSocket {
		
		var pipe = ctx.createSocket(ZMQ_PAIR);
		if (pipe == null)
			return null;
		pipe.setsockopt(ZMQ_SNDHWM, 1);
		pipe.setsockopt(ZMQ_RCVHWM, 1);
		var uuid = generateuuid(8);
		var pipeUUID = bytesToHex(uuid);	// Creates a 16char uuidstring, based on a 8-byte uuid
		
		// Create context for attached thread.
		// Set main=false to prevent shadow context.destroy() from closing shared underlying ZMQContext object
		var forkCtx = ZContext.shadow(ctx);
		forkCtx.main = false;	
		var forkPipe = forkCtx.createSocket(ZMQ_PAIR);
		forkPipe.setsockopt(ZMQ_SNDHWM, 1);
		forkPipe.setsockopt(ZMQ_RCVHWM, 1);
				
#if (neko || cpp)
		pipe.bind("inproc://zctx-pipe-" + pipeUUID);
		forkPipe.connect("inproc://zctx-pipe-" + pipeUUID);
		
		Thread.create(callback(attachedShim_fn, thread_fn, forkCtx, forkPipe, args));
#elseif php
		pipe.bind("ipc://tmp/zctx-pipe-" + pipeUUID);
		forkPipe.connect("ipc://tmp/zctx-pipe-" + pipeUUID);

		untyped __php__('
		$pid = pcntl_fork();
		if ($pid == 0) {
			// Running in child process
			thread_fn($forkCtx, $forkPipe, $args);
			$forkCtx->destroy();
			exit();
		}');
#end		
		return pipe;
	}
	
	private static function bytesToHex(bytes:Bytes):String {
		if (bytes == null)
			return null;
		var buf:StringBuf = new StringBuf();
		for (b in 0 ... bytes.length)
			buf.add(StringTools.hex(bytes.get(b), 2));
		return buf.toString();	
	}
	
	private static function generateuuid(len:Int):Bytes {
		var uuid:Bytes = Bytes.alloc(len);
		for (b in 0 ... len) {
			uuid.set(b, Std.random(255));
		}
		return uuid;
	}
}