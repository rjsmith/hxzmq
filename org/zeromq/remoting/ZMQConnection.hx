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
 * 
 * Sections of this class code were copied from the haxe.remoting.SocketConnection class in the standard haXe distribution
 * Copyright (c) 2005-2007, The haXe Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

package org.zeromq.remoting;

import org.zeromq.remoting.SocketProtocol;
import haxe.remoting.AsyncConnection;
import haxe.remoting.Context;

/**
 * This class provides a haXe remoting adapter using the zeroMQ message 
 * library (via hxzmq) as the transport layer
 */
class ZMQConnection implements AsyncConnection, implements Dynamic<AsyncConnection>
{

	var __path : Array<String>;
	var __data : {
		protocol : ZMQSocketProtocol,
		results : List<{ onResult : Dynamic -> Void, onError : Dynamic -> Void }>,
		log : Array<String> -> Array<Dynamic> -> Dynamic -> Void,
		error : Dynamic -> Void,
	};

	function new(data,path) {
		__data = data;
		__path = path;
	}

	public function resolve(name) : AsyncConnection {
		var s = new ZMQConnection(__data,__path.copy());
		s.__path.push(name);
		return s;
	}

	public function call( params : Array<Dynamic>, ?onResult : Dynamic -> Void ) {
		try {
			__data.protocol.sendRequest(__path,params);
			__data.results.add({ onResult : onResult, onError : __data.error });
		} catch( e : Dynamic ) {
			__data.error(e);
		}
	}

	public function setErrorHandler(h) {
		__data.error = h;
	}

	public function setErrorLogger(h) {
		__data.log = h;
	}

	public function setProtocol( p : ZMQSocketProtocol ) {
		__data.protocol = p;
	}

	public function getProtocol() : ZMQSocketProtocol {
		return __data.protocol;
	}

	public function close() {
		try __data.protocol.socket.close() catch( e : Dynamic ) { };
	}

	public function processMessage( data : String ) {
		var request;
		var proto = __data.protocol;
		data = proto.decodeData(data);
		try {
			request = proto.isRequest(data);
		} catch( e : Dynamic ) {
			var msg = Std.string(e) + " (in "+StringTools.urlEncode(data)+")";
			__data.error(msg); // protocol error
			return;
		}
		// request
		if( request ) {
			try proto.processRequest(data,__data.log) catch( e : Dynamic ) __data.error(e);
			return;
		}
		// answer
		var f = __data.results.pop();
		if( f == null ) {
			__data.error("No response excepted ("+data+")");
			return;
		}
		var ret;
		try {
			ret = proto.processAnswer(data);
		} catch( e : Dynamic ) {
			f.onError(e);
			return;
		}
		if( f.onResult != null ) f.onResult(ret);
	}

	function defaultLog(path,args,e) {
		// exception inside the called method
		var astr, estr;
		try astr = args.join(",") catch( e : Dynamic ) astr = "???";
		try estr = Std.string(e) catch( e : Dynamic ) estr = "???";
		var header = "Error in call to "+path.join(".")+"("+astr+") : ";
		__data.error(header + estr);
	}

	public static function create( s : ZMQSocket, ?ctx : Context ) {
		var data = {
			protocol : new ZMQSocketProtocol(s,ctx),
			results : new List(),
			error : function(e) throw e,
			log : null,
		};
		var sc = new ZMQConnection(data,[]);
		data.log = sc.defaultLog;
		return sc;
	}


}