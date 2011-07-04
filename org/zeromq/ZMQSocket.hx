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
#if php
import org.zeromq.externals.phpzmq.ZMQSocketException;
#end

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
     * Holds type of socket
     */
    public var type(default, null):SocketType;
    
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
		this.type = type;
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
		if (_socketHandle == null || closed)
			throw new ZMQException(ENOTSUP);
		
		try {
#if (neko || cpp)            
			_hx_zmq_bind(_socketHandle, Lib.haxeToNeko(addr));
#elseif php
            untyped __php__('$this->_socketHandle->bind($addr)');
#end            
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
        }
#if php            
		  catch (e:ZMQSocketException) {
            throw new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
        }
#end		
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
		if (_socketHandle == null || closed)
			throw new ZMQException(ENOTSUP);
		
		try {
#if (neko || cpp)            
			_hx_zmq_connect(_socketHandle, Lib.haxeToNeko(addr));
#elseif php
            untyped __php__('$this->_socketHandle->connect($addr)');
#end            
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
#if php            
		  catch (e:ZMQSocketException) {
            throw new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
        }
#end		
		
	}
	
	/**
	 * Set socket options.
	 * 
	 * See the ZMQ documentation for details on specific options: 
	 * http://api.zeromq.org/master:zmq-setsockopt
	 * 
	 * C Parameter type     optval haXe type expected
     * =================    ==========================
     * int                  Int
     * int64_t, uint64_t    ZMQInt64Type (if neko or cpp)
     *                      Int (if php - will be 64bits on 64bit platforms, else 32 bit)
     * binary               haxe.io.Bytes
     * 
	 * @param	option		SocketOptionsType (defined in ZMQ.hx)
	 * @param	optval		Either Int or String or Bytes
	 */
	public function setsockopt(option:SocketOptionsType, optval:Dynamic):Void {

		if (_socketHandle == null || closed)
			throw new ZMQException(ENOTSUP);
                    
        var _opt = ZMQ.socketOptionTypeNo(option);
           
		// Handle 32 bit int options
		if (Lambda.exists(ZMQ.intSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
			if (!Std.is(optval,Int))
				throw new String("Expected Int, got " + optval);
		
			try {	
#if (neko || cpp)                
				_hx_zmq_setintsockopt(_socketHandle, _opt, optval);
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			}
#elseif php
                untyped __php__('$this->_socketHandle->setsockopt($_opt, $optval)');
            } catch (e:ZMQSocketException) {
                new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
            }
#end  
			
		// Handle 64 bit int options	
		} else if (Lambda.exists(ZMQ.int64SocketOptionTypes,
			  function(so) { return so == option; } ))
		{
#if (neko || cpp)            
			var _hi = Reflect.field(optval, "hi");
			var _lo = Reflect.field(optval, "lo");
			if (_hi == null || _lo == null) {
				throw new String("Expected ZMQInt64Type, got " + optval);
				return null;
			}
#elseif php
			if (!Std.is(optval,Int))
				throw new String("Expected Int, got " + optval);
#end

			try {	
#if (neko || cpp)                
				_hx_zmq_setint64sockopt(_socketHandle, _opt, _hi, _lo);
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			}
#elseif php
                // If PHPO runing on 64 bit platform, haXe Int is already 64 bits.
                // If PHP is running on 32 bits, the setsockopt function converts the input to long (from int)
                untyped __php__('$this->_socketHandle->setsockopt($_opt, $optval)');
            } catch (e:ZMQSocketException) {
                new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
            }            
#end
			
		// Handle bytes  options	
		} else if (Lambda.exists(ZMQ.bytesSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
			if (!Std.is(optval, Bytes)) {
				throw new String("Expected Bytes, got " + optval);
				return null;
			}
			try {	
#if (neko || cpp)                
				_hx_zmq_setbytessockopt(_socketHandle, _opt, optval.getData() );
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
			}
#elseif php
                var v = optval.toString();
                untyped __php__('$this->_socketHandle->setsockopt($_opt, $v)');
            } catch (e:ZMQSocketException) {
                new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
            }
#end               
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
		var _optval:Dynamic = null;
        var _opt = ZMQ.socketOptionTypeNo(option);
		
		if (_socketHandle == null || closed) {
			throw new ZMQException(ENOTSUP);
			return null;
		}

		if (Lambda.exists(ZMQ.intSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
		
			try {	
#if (neko || cpp)        
				_optval = Lib.nekoToHaxe(_hx_zmq_getintsockopt(_socketHandle, _opt));
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
#elseif php
                return untyped __php__('$this->_socketHandle->getSockOpt($_opt)');
            }
            catch (e:ZMQSocketException) {
                throw new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
            }
#end

		} else if (Lambda.exists(ZMQ.int64SocketOptionTypes,
			  function(so) { return so == option; } ))
		{
		
#if php
 			try {	
                 return untyped __php__('$this->_socketHandle->getSockOpt($_opt)');
            }
            catch (e:ZMQSocketException) {
                throw new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
            }
#elseif (neko || cpp)                
			try {	
				_optval = Lib.nekoToHaxe(_hx_zmq_getint64sockopt(_socketHandle, _opt));
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
 #end
                
		}else if (Lambda.exists(ZMQ.bytesSocketOptionTypes,
			  function(so) { return so == option; } ))
		{
		
			try {	
#if (neko || cpp)                
				_optval = _hx_zmq_getbytessockopt(_socketHandle, _opt);
			} catch (e:Int) {
				throw new ZMQException(ZMQ.errNoToErrorType(e));
				return null;
			}
			return Bytes.ofData(_optval);
#elseif php
                var res = untyped __php__('$this->_socketHandle->getSockOpt($_opt)');
                return Bytes.ofString(res);
            } catch (e:ZMQSocketException) {
                throw new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
            }
#end
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

		if (_socketHandle == null || closed) {
			throw new ZMQException(ENOTSUP);
		}

		try {
#if (neko || cpp)            
			_hx_zmq_send(_socketHandle, data.getData(), ZMQ.sendReceiveFlagNo(flags));
#elseif php

            untyped __php__('$this->_socketHandle->send($data->toString(), org_zeromq_ZMQ::sendReceiveFlagNo($flags))');
#end            
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
#if php            
		  catch (e:ZMQSocketException) {
            throw new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
        }
#end		
			
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

		if (_socketHandle == null || closed)
			throw new ZMQException(ENOTSUP);

		var bytes:BytesData = null;
		
		try {
#if (neko || cpp)            
			bytes = _hx_zmq_rcv(_socketHandle, ZMQ.sendReceiveFlagNo(flags));
            return {
                if (bytes == null) {
                    null; 
                } else {
                    Bytes.ofData(bytes);
                };
		}
#elseif php
            var r:String = _hx_zmq_rcv(_socketHandle, ZMQ.sendReceiveFlagNo(flags));
            if (r != null) {
                return Bytes.ofString(r);
            } else
                return null;
#end                
		} catch (e:Int) {
			throw new ZMQException(ZMQ.errNoToErrorType(e));
		} 
#if php            
		  catch (e:ZMQSocketException) {
            throw new org.zeromq.ZMQException(ZMQ.errNoToErrorType(e.getCode()), e.getMessage());
        }
#end		
		
			
	}
	
	/**
	 * Convenience method to test if socket has more parts of a multipart message to read
	 * @return
	 */
	public function hasReceiveMore():Bool {
		if (_socketHandle == null || closed) return false;
		var r = getsockopt(ZMQ_RCVMORE);
#if (neko || cpp)        
		return (r != null && r.lo == 1);
#elseif php
		return (r != null && r == 1);
#end
	}
	
#if (neko || cpp)    
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
#elseif php
    private static  function _hx_zmq_construct_socket(context:Dynamic, type:Int):Dynamic {
        return untyped __php__('new ZMQSocket($context, $type)');
    }
    private static function _hx_zmq_close(socket:Dynamic):Void {
        untyped __call__('unset', socket); 
    }
    private static  function _hx_zmq_send(socket:Dynamic, msg:Dynamic, mode:Int):Void {
        untyped __php__('$socket->send($msg, $mode)');
    }
    private static  function _hx_zmq_rcv(socket:Dynamic, mode:Int):String {
        var r:Dynamic = untyped __php__('$socket->recv($mode)');
        // Detect if php has returned boolean false value (if NOBLOCK/DONTWAIT used)
        if (Std.is(r, Bool) && !r)
            return null;
        else
            return Std.string(r);
    }

#end
}
