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

import haxe.io.Bytes;
import haxe.io.BytesData;
import neko.Lib;
import neko.Sys;

import org.zeromq.ZMQ;

/**
 * A 0MQ socket
 * 
 * These objects will generally be created via the socket() method of a ZMQContext object.
 * 
 * Class based on code from pyzmq project
 * See: https://github.com/zeromq/pyzmq/blob/master/zmq/core/socket.pyx
 */
class ZMQSocket 
{

	/** Records if socket has been closed */
	public var closed(default,null):Bool;
	
	/**
	 * Hold reference to context associated with socket, to stop it being garbage collected
	 */
	public var context(default,null):ZMQContext;
	
	/** Opaque data used by hxzmq driver */
 	public var _socketHandle(default,null):Dynamic;

	/**
	 * Constructor.
	 * 
	 * Creates a new ZMQ socket
	 * @param	context		A ZMQ Context previously created
	 * @param	type		A ZMQ socket type
	 */
	public function new(context:ZMQContext, type:SocketType) 
	{
		closed = true;
		this.context = context;
		try {
			_socketHandle = _hx_zmq_construct_socket(context.contextHandle, ZMQ.socketTypeNo(type));
			
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
		
		closed = false;
	}
	
	/**
	 * Close the socket
	 * 
	 * This can be called to close the socket by hand. If this is not
	 * called, the socket will automatically be closed when it is
	 * garbage collected.
	 */
	public function close()
	{
		if (_socketHandle != null && !closed) {
			try {
				_hx_zmq_close(_socketHandle);
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			} 
			
			closed = true;
			_socketHandle = null;
		}
	}
	
	/**
	 * Bind a socket to an address
	 * 
	 * This causes the socket to listen on a network port. Sockets on the
	 * other side of this connection will use ``Socket.connect(addr)`` to
	 * connect to this socket.
	 * 
	 * @param	addr	The address string.
	 * 				This has the form 'protocol://interface:port',
	 * 				for example 'tcp://127.0.0.1:5555'. Protocols supported are
	 * 				tcp, upd, pgm, inproc and ipc. If the address is unicode, it is
	 * 				encoded to utf-8 first.
	 */
	public function bind(addr:String)
	{
		if (closed)
			throw new ZMQException(ENOTSUP);
		
		try {
			_hx_zmq_bind(_socketHandle, Lib.haxeToNeko(addr));
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
		
	}

	/**
	 * Connect to a remote ZMQ socket
	 * 
	 * @param	addr	The address string
	 * 				This has the form 'protocol://interface:port',
	 * 				for example 'tcp://127.0.0.1:5555'. Protocols supported are
	 * 				tcp, upd, pgm, inproc and ipc. If the address is unicode, it is
	 * 				encoded to utf-8 first.
	 */
	public function connect(addr:String)
	{
		if (closed)
			throw new ZMQException(ENOTSUP);
		
		try {
			_hx_zmq_connect(_socketHandle, Lib.haxeToNeko(addr));
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
		
	}
	
	/**
	 * Set socket options.
	 * 
	 * See the ZMQ documentation for details on specific options: 
	 * http://api.zeromq.org/master:zmq-setsockopt
	 * 
	 * 
	 * @param	option		SocketOptionsType (defined in ZMQ.hx)
	 * @param	optval		Either Int or String or Bytes
	 */
	public function setsockopt(option:SocketOptionsType, optval:Dynamic):Void {

		if (closed)
			throw new ZMQException(ENOTSUP);

		// Handle 32 bit int options
		if (Lambda.exists(ZMQ.intSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
			if (!Std.is(optval,Int))
				throw new String("Expected Int, got " + optval);
		
			try {	
				_hx_zmq_setintsockopt(_socketHandle, ZMQ.socketOptionTypeNo(option), optval);
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			}
			
		// Handle 64 bit int options	
		} else if (Lambda.exists(ZMQ.int64SocketOptionTypes,
			  function(so) { return so == option; } ))
		{
			var _hi = Reflect.field(optval, "hi");
			var _lo = Reflect.field(optval, "lo");
			if (_hi == null || _lo == null) {
				throw new String("Expected ZMQInt64Type, got " + optval);
				return null;
			}
			
			try {	
				_hx_zmq_setint64sockopt(_socketHandle, ZMQ.socketOptionTypeNo(option), _hi, _lo);
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			}
			
		// Handle bytes  options	
		} else if (Lambda.exists(ZMQ.bytesSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
			if (!Std.is(optval, Bytes)) {
				throw new String("Expected Bytes, got " + optval);
				return null;
			}
			try {	
				_hx_zmq_setbytessockopt(_socketHandle, ZMQ.socketOptionTypeNo(option), optval.getData() );
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			}
				
		} else {
			throw new ZMQException(EINVAL);
		}
		return;	
	}
	
	/**
	 * Return a previously set socket option
	 * 
	 * @param	option
	 * @return
	 */
	public function getsockopt(option:SocketOptionsType):Dynamic 
	{
		var _optval:Dynamic;
		
		if (closed) {
			throw new ZMQException(ENOTSUP);
			return null;
		}

		if (Lambda.exists(ZMQ.intSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
		
			try {	
				_optval = Lib.nekoToHaxe(_hx_zmq_getintsockopt(_socketHandle, ZMQ.socketOptionTypeNo(option)));
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
				return null;
			}
			if (!Std.is(_optval,Int)) {
				throw new String("Expected Int, got " + _optval);
				return null;
			} else {
				return _optval;
			}
		} else if (Lambda.exists(ZMQ.int64SocketOptionTypes,
			  function(so) { return so == option; } ))
		{
		
			try {	
				_optval = Lib.nekoToHaxe(_hx_zmq_getint64sockopt(_socketHandle, ZMQ.socketOptionTypeNo(option)));
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
				return null;
			}
			var _hi = Reflect.field(_optval, "hi");
			var _lo = Reflect.field(_optval, "lo");
			if (_hi == null || _lo == null) {
				throw new String("Expected ZMQInt64Type, got " + _optval);
				return null;
			} else {
				return {hi:_optval.hi, lo:_optval.lo};
			}
		}else if (Lambda.exists(ZMQ.bytesSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
		
			try {	
				_optval = _hx_zmq_getbytessockopt(_socketHandle, ZMQ.socketOptionTypeNo(option));
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
				return null;
			}
			return Bytes.ofData(_optval);
			
		} else {
			throw new ZMQException(EINVAL);
			return null;
		}
		return null;
		
	}
	
	/**
	 * Send a message on this socket
	 * 
	 * This queues the message to be sent by the IO thread at a later time.
	 * 
	 * @param	data	The content of the message
	 * @param	?flags	Any supported SocketFlag DONTWAIT, SNDMORE
	 */
	public function sendMsg(data:Bytes, ?flags:SendReceiveFlagType):Void {

		if (closed) {
			throw new ZMQException(ENOTSUP);
		}

		try {
			_hx_zmq_send(_socketHandle, data.getData(), ZMQ.sendReceiveFlagNo(flags));
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
			
	}

	/**
	 * Receive a message on this socket
	 * 
	 * Will return either a message, null (if DONTWAIT was used and there was no data received) or a ZMQException
	 * 
	 * @param	?flags
	 * @return
	 */
	public function recvMsg(?flags:SendReceiveFlagType):Bytes {

		if (closed)
			throw new ZMQException(ENOTSUP);

		var bytes:BytesData = null;
		
		try {
			bytes = _hx_zmq_rcv(_socketHandle, ZMQ.sendReceiveFlagNo(flags));
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
		
		return {
			if (bytes == null) {
				null; 
			} else {
				Bytes.ofData(bytes);
			};
		}
			
	}
	
	/**
	 * Convenience method to test if socket has more parts of a multipart message to read
	 * @return
	 */
	public function hasReceiveMore():Bool {
		if (closed) return false;
		var r = getsockopt(ZMQ_RCVMORE);
		return (r != null && r.lo == 1);
	}
	
	private static var _hx_zmq_construct_socket = neko.Lib.load("hxzmq", "hx_zmq_construct_socket", 2);
	private static var _hx_zmq_close = neko.Lib.load("hxzmq", "hx_zmq_close", 1);
	private static var _hx_zmq_bind = neko.Lib.load("hxzmq", "hx_zmq_bind", 2);
	private static var _hx_zmq_connect = neko.Lib.load("hxzmq", "hx_zmq_connect", 2);
	private static var _hx_zmq_send = neko.Lib.load("hxzmq", "hx_zmq_send", 3);
	private static var _hx_zmq_rcv = neko.Lib.load("hxzmq", "hx_zmq_rcv", 2);
	private static var _hx_zmq_setintsockopt = neko.Lib.load("hxzmq", "hx_zmq_setintsockopt", 3);
	private static var _hx_zmq_setint64sockopt = neko.Lib.load("hxzmq", "hx_zmq_setint64sockopt", 4);
	private static var _hx_zmq_setbytessockopt = neko.Lib.load("hxzmq", "hx_zmq_setbytessockopt", 3);
	private static var _hx_zmq_getintsockopt = neko.Lib.load("hxzmq", "hx_zmq_getintsockopt", 2);
	private static var _hx_zmq_getint64sockopt = neko.Lib.load("hxzmq", "hx_zmq_getint64sockopt", 2);
	private static var _hx_zmq_getbytessockopt = neko.Lib.load("hxzmq", "hx_zmq_getbytessockopt", 2);
	
}
