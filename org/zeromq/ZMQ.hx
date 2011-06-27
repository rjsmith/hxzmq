/*
  Copyright (c) 2011 Richard J Smith

  This file is part of hxzmq.

  hxzmq is free software; you can redistribute it and/or modify it under
  the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.

  hxzmq is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.zeromq;

import haxe.Int32;
import haxe.io.Bytes;
import org.zeromq.ZMQContext;
import neko.Lib;

/**
 * Enumeration of 0MQ socket types
 */
enum SocketType {
	ZMQ_PAIR;
	ZMQ_PUB;
	ZMQ_SUB;
	ZMQ_REQ;
	ZMQ_REP;
	ZMQ_ROUTER;		// Replaces XREQ in 2.1.4
	ZMQ_DEALER;		// Replaces XREP in 2.1.4
	ZMQ_PULL;
	ZMQ_PUSH;	
}

/**
 * Enumeration of 0MQ error types
 */
enum ErrorType {
	EINVAL;
	ENOTSUP;
	EPROTONOSUPPORT;
	EAGAIN;
	ENOMEM;
	ENODEV;
	ENOBUFS;
	ENETDOWN;
	EADDRINUSE;
	EADDRNOTAVAIL;
	ECONNREFUSED;
	EINPROGRESS;
	EMTHREAD;
	EFSM;
	ENOCOMPATPROTO;
	ETERM;
}

/**
 * Enumeration of 0MQ send and receive flags
 */
enum SendReceiveFlagType {
	DONTWAIT;	// ZMQSocket flag to indicate a nonblocking send or recv mode.
				// Maps to underlying NOBLOCK in 0MQ 2.1.x
	SNDMORE;	// ZMQSocket flag to indicate that more message parts are coming.
}

/**
 * Enumeration of 0MQ socket types
 * See: http://api.zeromq.org/master:zmq-setsockopt
 */
enum SocketOptionsType {
	ZMQ_HWM;			// Set high water mark
	ZMQ_SWAP;			// Set disk offload size
	ZMQ_AFFINITY;		// Set I/O thread affinity
	ZMQ_IDENTITY;		// Set socket identity
	ZMQ_SUBSCRIBE;		// Establish message filter
	ZMQ_UNSUBSCRIBE;	// Remove message filter
	ZMQ_RATE;			// Set multicast data rate
	ZMQ_RECOVERY_IVL;	// Set multicast recovery interval
	ZMQ_RECOVERY_IVL_MSEC;	// Set multicast recovery interval in milliseconds
	ZMQ_MCAST_LOOP;		// Control multicast loop-back
	ZMQ_SNDBUF;			// Set kernel transmit buffer size
	ZMQ_RCVBUF;			// Set kernel receive buffer size
	ZMQ_LINGER;			// Set linger period for socket shutdown
	ZMQ_RCVMORE;		// More message parts to follow flag
	ZMQ_RECONNECT_IVL;	// Set reconnection interval
	ZMQ_RECONNECT_IVL_MAX;	// Set maximum reconnection interval
	ZMQ_BACKLOG;		// Set maximum length of the queue of outstanding connections
	ZMQ_FD;				// Retrieve file descriptor associated with the socket
	ZMQ_EVENTS;			// Retrieve socket event state (bitmask use ZMQ_POLLIN and ZMQ_POLLOUT)
	ZMQ_TYPE;			// Retrieves type of socket
}

/**
 * Used to pass 64 bit ints to setlongsockopt
 */
typedef ZMQInt64Type = { hi:Int, lo:Int };

/**
 * Core class for 0MQ Haxe bindings
 */
class ZMQ {
	
   // Values for flags in ZMQSocket's send and recv functions.
   public static var bytesSocketOptionTypes:Array<SocketOptionsType> = 
		[
			ZMQ_IDENTITY,
			ZMQ_SUBSCRIBE,
			ZMQ_UNSUBSCRIBE
		];
   public static var int64SocketOptionTypes:Array<SocketOptionsType> = 
		[
			ZMQ_HWM,
			ZMQ_SWAP,
			ZMQ_AFFINITY,
			ZMQ_RATE,
			ZMQ_RECOVERY_IVL,
			ZMQ_RECOVERY_IVL_MSEC,
			ZMQ_MCAST_LOOP,
			ZMQ_SNDBUF,
			ZMQ_RCVBUF,
			ZMQ_RCVMORE
		];
	
   public static var intSocketOptionTypes:Array<SocketOptionsType> = 
		[
			ZMQ_LINGER,
			ZMQ_RECONNECT_IVL,
			ZMQ_RECONNECT_IVL_MAX,
			ZMQ_BACKLOG,
			ZMQ_FD, 	// Only int on POSIX systems
			ZMQ_EVENTS,
			ZMQ_TYPE
		];
	
   
    /**
     * Flag to specify a STREAMER device.
     */
    public static inline var STREAMER = 1;

    /**
     * Flag to specify a FORWARDER device.
     */
    public static inline var FORWARDER = 2;

    /**
     * Flag to specify a QUEUE device.
     */
    public static inline var QUEUE = 3;
		
	// Bitmask flags for ZMQ_EVENTS socket event option query

	public static inline function ZMQ_POLLIN():Int {
		return _hx_zmq_ZMQ_POLLIN();
	}
	public static inline function ZMQ_POLLOUT():Int {
		return _hx_zmq_ZMQ_POLLOUT();
	}
	public static inline function ZMQ_POLLERR():Int {
		return _hx_zmq_ZMQ_POLLERR();
	}
	
	/**
	 * Gets complete 0MQ library version 
	 * @return		0MQ library version in form MMmmpp (MM=major, mm=minor, pp=patch)
	 */
	public static function version_full():Int
	{
		return _hx_zmq_version_full();
	}

	/**
	 * Gets 0MQ library major version
	 * @return		0MQ major library version (2, 3 etc)
	 */
	public static function versionMajor():Int
	{
		return _hx_zmq_version_major();
	}

	/**
	 * Gets 0MQ library minor version
	 * @return		0MQ minor library version
	 */
	public static function versionMinor():Int
	{
		return _hx_zmq_version_minor();
	}

	/**
	 * Gets 0MQ library patch version
	 * @return		0MQ library patch version
	 */
	public static function versionPatch():Int
	{
		return _hx_zmq_version_patch();
	}
	
	/**
	 * Creates an integer in same form as given by versionFull()
	 * @param	major
	 * @param	minor
	 * @param	patch
	 * @return
	 */
	public static function makeVersion(major:Int, minor:Int, patch:Int):Int
	{
		return _hx_zmq_make_version(major, minor, patch);
	}
	
	/**
	 * Returns a human-readable description from a ZMQException object errNo number
	 * @param	errNo		A valid 0MQ error number.
	 * 						Use the errorTypeToErrNo method to convert a ZMQ.ErrorType
	 * @return				A short description of the error
	 */
	public static function strError(e:Int):String
	{
#if php
        return _hx_zmq_str_error(e);
#else        
		return Lib.nekoToHaxe(_hx_zmq_str_error(e));
#end        
	}

	/**
	 * Converts a SocketType enum into a ZMQ socket type integer value
	 * @param	type
	 * @return
	 */
	public static function socketTypeNo(type:SocketType):Int {
		return {
			switch(type) {
				case ZMQ_PUB:
					_hx_zmq_ZMQ_PUB();
				case ZMQ_SUB:
					_hx_zmq_ZMQ_SUB();
				case ZMQ_PAIR:
					_hx_zmq_ZMQ_PAIR();
				case ZMQ_REQ:
					_hx_zmq_ZMQ_REQ();
				case ZMQ_REP:
					_hx_zmq_ZMQ_REP();
				case ZMQ_ROUTER:
					_hx_zmq_ZMQ_ROUTER();
				case ZMQ_DEALER:
					_hx_zmq_ZMQ_DEALER();
				case ZMQ_PULL:
					_hx_zmq_ZMQ_PULL();
				case ZMQ_PUSH:
					_hx_zmq_ZMQ_PUSH();
				default:
					null;
			}
		}
	}

	/**
	 * Converts a SocketOptionsType enum into a ZMQ int
	 * @param	option
	 * @return
	 */
	public static function socketOptionTypeNo(option:SocketOptionsType):Int {
		return {
			switch(option) {
				case ZMQ_LINGER:
					_hx_zmq_ZMQ_LINGER();
				case ZMQ_HWM:
					_hx_zmq_ZMQ_HWM();
				case ZMQ_SWAP:
					_hx_zmq_ZMQ_SWAP();
				case ZMQ_AFFINITY:
					_hx_zmq_ZMQ_AFFINITY();
				case ZMQ_IDENTITY:
					_hx_zmq_ZMQ_IDENTITY();
				case ZMQ_SUBSCRIBE:
					_hx_zmq_ZMQ_SUBSCRIBE();
				case ZMQ_UNSUBSCRIBE:
					_hx_zmq_ZMQ_UNSUBSCRIBE();
				case ZMQ_RATE:
					_hx_zmq_ZMQ_RATE();
				case ZMQ_RECOVERY_IVL:
					_hx_zmq_ZMQ_RECOVERY_IVL();
				case ZMQ_RECOVERY_IVL_MSEC:
					_hx_zmq_ZMQ_RECOVERY_IVL_MSEC();
				case ZMQ_MCAST_LOOP:
					_hx_zmq_ZMQ_MCAST_LOOP();
				case ZMQ_SNDBUF:
					_hx_zmq_ZMQ_SNDBUF();
				case ZMQ_RCVBUF:
					_hx_zmq_ZMQ_RCVBUF();
				case ZMQ_RECONNECT_IVL:
					_hx_zmq_ZMQ_RECONNECT_IVL();
				case ZMQ_RECONNECT_IVL_MAX:
					_hx_zmq_ZMQ_RECONNECT_IVL_MAX();
				case ZMQ_BACKLOG:
					_hx_zmq_ZMQ_BACKLOG();
				case ZMQ_RCVMORE:
					_hx_zmq_ZMQ_RCVMORE();
				case ZMQ_FD:
					_hx_zmq_ZMQ_FD();
				case ZMQ_EVENTS:
					_hx_zmq_ZMQ_EVENTS();
				case ZMQ_TYPE:
					_hx_zmq_ZMQ_TYPE();
				default:
					null;
			}
		}
	}
	
	/**
	 * Converts a SendReceiveFlagType enum value into the corresponding 0MQ library int value
	 * @param	type
	 * @return
	 */
	public static function sendReceiveFlagNo(type:SendReceiveFlagType):Int {
		if (type == null) return null;
		return {
			switch(type) {
				case DONTWAIT:
					_hx_zmq_DONTWAIT();
				case SNDMORE:
					_hx_zmq_SNDMORE();
				default:
					null;
			}
		}
	}
	
	/**
	 * Converts Haxe ErrorType enum value to ZMQ errNo integer value
	 * @param	e
	 * @return
	 */
	public static function errorTypeToErrNo(e:ErrorType):Int {
		return {
			switch(e) {
				case EINVAL:
					_hx_zmq_EINVAL();
				case ENOTSUP:
					_hx_zmq_ENOTSUP();
				case EPROTONOSUPPORT:	
					_hx_zmq_EPROTONOSUPPORT();
				case EAGAIN:
					_hx_zmq_EAGAIN();
				case ENOMEM:
					_hx_zmq_ENOMEM();
				case ENODEV:
					_hx_zmq_ENODEV();
				case ENOBUFS:
					_hx_zmq_ENOBUFS();
				case ENETDOWN:
					_hx_zmq_ENETDOWN();
				case EADDRINUSE:
					_hx_zmq_EADDRINUSE();
				case EADDRNOTAVAIL:
					_hx_zmq_EADDRNOTAVAIL();
				case ECONNREFUSED:
					_hx_zmq_ECONNREFUSED();
				case EINPROGRESS:
					_hx_zmq_EINPROGRESS();
				case EMTHREAD:
					_hx_zmq_EMTHREAD();
				case EFSM:
					_hx_zmq_EFSM();
				case ENOCOMPATPROTO:
					_hx_zmq_ENOCOMPATPROTO();
				case ETERM:
					_hx_zmq_ETERM();
				default:
					0;		
			}
		}
	}
	
	/**
	 * Converts ZMQ errNo integer value to Haxe ErrorType enum value
	 * @param	e
	 * @return
	 */
	public static function errNoToErrorType(e:Int):ErrorType {
		return {
			switch (e) {
				case _hx_zmq_EINVAL():
					EINVAL;
				case _hx_zmq_ENOTSUP():
					ENOTSUP;
				case _hx_zmq_EPROTONOSUPPORT():
					EPROTONOSUPPORT;
				case _hx_zmq_EAGAIN():
					EAGAIN;
				case _hx_zmq_ENOMEM():
					ENOMEM;	
				case _hx_zmq_ENODEV():
					ENODEV;
				case _hx_zmq_ENOBUFS():
					ENOBUFS;
				case _hx_zmq_ENETDOWN():
					ENETDOWN;
				case _hx_zmq_EADDRINUSE():
					EADDRINUSE;
				case _hx_zmq_EADDRNOTAVAIL():
					EADDRNOTAVAIL;
				case _hx_zmq_ECONNREFUSED():
					ECONNREFUSED;
				case _hx_zmq_EINPROGRESS():
					EINPROGRESS;
				case _hx_zmq_EMTHREAD():
					EMTHREAD;
				case _hx_zmq_EFSM():
					EFSM;
				case _hx_zmq_ENOCOMPATPROTO():
					ENOCOMPATPROTO;
				case _hx_zmq_ETERM():
					ETERM;
				default:
					ENOTSUP;
			}
		}
	}
	
	/**
	 * Sets up interrupt signal handling.
	 * Use isInterrupted() to subsequwnrly test for interruption
	 */
	public static function catchSignals() {
		_hx_zmq_catch_signals();
	}
	
	/**
	 * Indicates if 0MQ has been interrupted by a system signal (SIGINT or SIGTERM)
	 * Use this method to detect interrupt, and exit cleanly (close 0MQ sockets and contexts),
	 * particularly after recvMsg() and poll() calls.
	 * See: http://zguide.zeromq.org/page:all#Handling-Interrupt-Signals
	 * 
	 * @return		True if 0MQ has been interrupted
	 */
	public static function isInterrupted():Bool {
		var i:Int = _hx_zmq_interrupted();
		return (i == 1);
	}
	
	#if (neko||cpp)
	//  Load function references from hxzmq.ndll
	private static var _hx_zmq_version_full = Lib.load("hxzmq", "hx_zmq_version_full",0);
	private static var _hx_zmq_version_major = Lib.load("hxzmq", "hx_zmq_version_major",0);
	private static var _hx_zmq_version_minor = Lib.load("hxzmq", "hx_zmq_version_minor",0);
	private static var _hx_zmq_version_patch = Lib.load("hxzmq", "hx_zmq_version_patch",0);
	private static var _hx_zmq_make_version = Lib.load("hxzmq", "hx_zmq_make_version", 3);
	private static var _hx_zmq_str_error = Lib.load("hxzmq", "hx_zmq_str_error", 1);
	private static var _hx_zmq_catch_signals = Lib.load("hxzmq", "hx_zmq_catch_signals", 0);
	private static var _hx_zmq_interrupted = Lib.load("hxzmq", "hx_zmq_interrupted", 0);
	
	private static var _hx_zmq_ZMQ_PUB = Lib.load("hxzmq", "hx_zmq_ZMQ_PUB", 0);
	private static var _hx_zmq_ZMQ_SUB = Lib.load("hxzmq", "hx_zmq_ZMQ_SUB", 0);
	private static var _hx_zmq_ZMQ_PAIR = Lib.load("hxzmq", "hx_zmq_ZMQ_PAIR", 0);
	private static var _hx_zmq_ZMQ_REQ = Lib.load("hxzmq", "hx_zmq_ZMQ_REQ", 0);
	private static var _hx_zmq_ZMQ_REP = Lib.load("hxzmq", "hx_zmq_ZMQ_REP", 0);
	private static var _hx_zmq_ZMQ_DEALER = Lib.load("hxzmq", "hx_zmq_ZMQ_DEALER", 0);
	private static var _hx_zmq_ZMQ_ROUTER = Lib.load("hxzmq", "hx_zmq_ZMQ_ROUTER", 0);
	private static var _hx_zmq_ZMQ_PULL = Lib.load("hxzmq", "hx_zmq_ZMQ_PULL", 0);
	private static var _hx_zmq_ZMQ_PUSH = Lib.load("hxzmq", "hx_zmq_ZMQ_PUSH", 0);
	
	private static var _hx_zmq_ZMQ_LINGER = Lib.load("hxzmq", "hx_zmq_ZMQ_LINGER", 0);
	private static var _hx_zmq_ZMQ_HWM = Lib.load("hxzmq", "hx_zmq_ZMQ_HWM", 0);
	private static var _hx_zmq_ZMQ_RCVMORE = Lib.load("hxzmq", "hx_zmq_ZMQ_RCVMORE", 0);
	private static var _hx_zmq_ZMQ_SUBSCRIBE = Lib.load("hxzmq", "hx_zmq_ZMQ_SUBSCRIBE", 0);
	private static var _hx_zmq_ZMQ_UNSUBSCRIBE = Lib.load("hxzmq", "hx_zmq_ZMQ_UNSUBSCRIBE", 0);
	private static var _hx_zmq_ZMQ_SWAP = Lib.load("hxzmq", "hx_zmq_ZMQ_SWAP", 0);
	private static var _hx_zmq_ZMQ_AFFINITY = Lib.load("hxzmq", "hx_zmq_ZMQ_AFFINITY", 0);
	private static var _hx_zmq_ZMQ_IDENTITY = Lib.load("hxzmq", "hx_zmq_ZMQ_IDENTITY", 0);

	private static var _hx_zmq_ZMQ_RATE = Lib.load("hxzmq", "hx_zmq_ZMQ_RATE", 0);
	private static var _hx_zmq_ZMQ_RECOVERY_IVL = Lib.load("hxzmq", "hx_zmq_ZMQ_RECOVERY_IVL", 0);
	private static var _hx_zmq_ZMQ_RECOVERY_IVL_MSEC = Lib.load("hxzmq", "hx_zmq_ZMQ_RECOVERY_IVL_MSEC", 0);
	private static var _hx_zmq_ZMQ_MCAST_LOOP = Lib.load("hxzmq", "hx_zmq_ZMQ_MCAST_LOOP", 0);
	private static var _hx_zmq_ZMQ_SNDBUF = Lib.load("hxzmq", "hx_zmq_ZMQ_SNDBUF", 0);
	private static var _hx_zmq_ZMQ_RCVBUF = Lib.load("hxzmq", "hx_zmq_ZMQ_RCVBUF", 0);
	private static var _hx_zmq_ZMQ_RECONNECT_IVL = Lib.load("hxzmq", "hx_zmq_ZMQ_RECONNECT_IVL", 0);
	private static var _hx_zmq_ZMQ_RECONNECT_IVL_MAX = Lib.load("hxzmq", "hx_zmq_ZMQ_RECONNECT_IVL_MAX", 0);
	private static var _hx_zmq_ZMQ_BACKLOG = Lib.load("hxzmq", "hx_zmq_ZMQ_BACKLOG", 0);
	private static var _hx_zmq_ZMQ_FD = Lib.load("hxzmq", "hx_zmq_ZMQ_FD", 0);
	private static var _hx_zmq_ZMQ_EVENTS = Lib.load("hxzmq", "hx_zmq_ZMQ_EVENTS", 0);
	private static var _hx_zmq_ZMQ_TYPE = Lib.load("hxzmq", "hx_zmq_ZMQ_TYPE", 0);
	
	private static var _hx_zmq_ZMQ_POLLIN = Lib.load("hxzmq", "hx_zmq_ZMQ_POLLIN", 0);
	private static var _hx_zmq_ZMQ_POLLOUT = Lib.load("hxzmq", "hx_zmq_ZMQ_POLLOUT", 0);
	private static var _hx_zmq_ZMQ_POLLERR = Lib.load("hxzmq", "hx_zmq_ZMQ_POLLERR", 0);

	private static var _hx_zmq_DONTWAIT = Lib.load("hxzmq", "hx_zmq_DONTWAIT", 0);
	private static var _hx_zmq_SNDMORE = Lib.load("hxzmq", "hx_zmq_SNDMORE", 0);
	
	private static var _hx_zmq_EINVAL = Lib.load("hxzmq", "hx_zmq_EINVAL", 0);
	private static var _hx_zmq_ENOTSUP = Lib.load("hxzmq", "hx_zmq_ENOTSUP", 0);
	private static var _hx_zmq_EPROTONOSUPPORT = Lib.load("hxzmq", "hx_zmq_EPROTONOSUPPORT", 0);
	private static var _hx_zmq_EAGAIN = Lib.load("hxzmq", "hx_zmq_EAGAIN", 0);
	private static var _hx_zmq_ENOMEM = Lib.load("hxzmq", "hx_zmq_ENOMEM", 0);
	private static var _hx_zmq_ENODEV = Lib.load("hxzmq", "hx_zmq_ENODEV", 0);
	private static var _hx_zmq_ENOBUFS = Lib.load("hxzmq", "hx_zmq_ENOBUFS", 0);
	private static var _hx_zmq_ENETDOWN = Lib.load("hxzmq", "hx_zmq_ENETDOWN", 0);
	private static var _hx_zmq_EADDRINUSE = Lib.load("hxzmq", "hx_zmq_EADDRINUSE", 0);
	private static var _hx_zmq_EADDRNOTAVAIL = Lib.load("hxzmq", "hx_zmq_EADDRNOTAVAIL", 0);
	private static var _hx_zmq_ECONNREFUSED = Lib.load("hxzmq", "hx_zmq_ECONNREFUSED", 0);
	private static var _hx_zmq_EINPROGRESS = Lib.load("hxzmq", "hx_zmq_EINPROGRESS", 0);
	private static var _hx_zmq_EMTHREAD = Lib.load("hxzmq", "hx_zmq_EMTHREAD", 0);
	private static var _hx_zmq_EFSM = Lib.load("hxzmq", "hx_zmq_EFSM", 0);
	private static var _hx_zmq_ENOCOMPATPROTO = Lib.load("hxzmq", "hx_zmq_ENOCOMPATPROTO", 0);
	private static var _hx_zmq_ETERM = Lib.load("hxzmq", "hx_zmq_ETERM", 0);
	
    #elseif php
    //      Load functions and constants from php-zmq
    

    private static function _hx_zmq_version_full():Int {
        return untyped __php__('ZMQ::LIBZMQ_VER');
    }
    // Not supported in php-zmq 0.7.0
    private static function _hx_zmq_version_major():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    // Not supported in php-zmq 0.7.0
    private static function _hx_zmq_version_minor():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    // Not supported in php-zmq 0.7.0
    private static function _hx_zmq_version_patch():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    // Not supported in php-zmq 0.7.0
    private static function _hx_zmq_make_version(major:Int, minor:Int, patch:Int):Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    // Not supported in php-zmq 0.7.0
	private static function _hx_zmq_str_error(e:Int):String {
        return "ZMQ Error";     // php-zmq doesnt expose the str_error function
    }
    private static function _hx_zmq_catch_signals():Void {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_interrupted():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    
    
    private static function _hx_zmq_ZMQ_PUB():Int {return untyped __php__('ZMQ::SOCKET_PUB');}
    private static function _hx_zmq_ZMQ_SUB():Int {return untyped __php__('ZMQ::SOCKET_SUB');}
    private static function _hx_zmq_ZMQ_PAIR():Int {return untyped __php__('ZMQ::SOCKET_PAIR');}
    private static function _hx_zmq_ZMQ_REQ():Int {return untyped __php__('ZMQ::SOCKET_REQ');}
    private static function _hx_zmq_ZMQ_REP():Int {return untyped __php__('ZMQ::SOCKET_REP');}
    private static function _hx_zmq_ZMQ_DEALER():Int {return untyped __php__('ZMQ::SOCKET_XREQ');}
    private static function _hx_zmq_ZMQ_ROUTER():Int {return untyped __php__('ZMQ::SOCKET_XREP');}
    private static function _hx_zmq_ZMQ_PULL():Int {return untyped __php__('ZMQ::SOCKET_PULL');}
    private static function _hx_zmq_ZMQ_PUSH():Int {return untyped __php__('ZMQ::SOCKET_PUSH');}
    
    
    private static function _hx_zmq_ZMQ_LINGER():Int {return untyped __php__('ZMQ::SOCKOPT_LINGER');}
    private static function _hx_zmq_ZMQ_HWM():Int {return untyped __php__('ZMQ::SOCKOPT_HWM');}
    private static function _hx_zmq_ZMQ_RCVMORE():Int {return untyped __php__('ZMQ::SOCKOPT_RCVMORE');}
    private static function _hx_zmq_ZMQ_SUBSCRIBE():Int {return untyped __php__('ZMQ::SOCKOPT_SUBSCRIBE');}
    private static function _hx_zmq_ZMQ_UNSUBSCRIBE():Int {return untyped __php__('ZMQ::SOCKOPT_UNSUBSCRIBE');}
    private static function _hx_zmq_ZMQ_SWAP():Int {return untyped __php__('ZMQ::SOCKOPT_SWAP');}
    private static function _hx_zmq_ZMQ_AFFINITY():Int {return untyped __php__('ZMQ::SOCKOPT_AFFINITY');}
    private static function _hx_zmq_ZMQ_IDENTITY():Int {return untyped __php__('ZMQ::SOCKOPT_IDENTITY');}

    private static function _hx_zmq_ZMQ_RATE():Int {return untyped __php__('ZMQ::SOCKOPT_RATE');}
    private static function _hx_zmq_ZMQ_RECOVERY_IVL():Int {return untyped __php__('ZMQ::SOCKOPT_RECOVERY_IVL');}
    private static function _hx_zmq_ZMQ_RECOVERY_IVL_MSEC():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_ZMQ_MCAST_LOOP():Int {return untyped __php__('ZMQ::SOCKOPT_MCAST_LOOP');}
    private static function _hx_zmq_ZMQ_SNDBUF():Int {return untyped __php__('ZMQ::SOCKOPT_SNDBUF');}
    private static function _hx_zmq_ZMQ_RCVBUF():Int {return untyped __php__('ZMQ::SOCKOPT_RCVBUF');}
    private static function _hx_zmq_ZMQ_RECONNECT_IVL():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_ZMQ_RECONNECT_IVL_MAX():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_ZMQ_BACKLOG():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_ZMQ_FD():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_ZMQ_EVENTS():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_ZMQ_TYPE():Int {return untyped __php__('ZMQ::SOCKOPT_TYPE');}

    private static function _hx_zmq_ZMQ_POLLIN():Int {return untyped __php__('ZMQ::POLL_IN');}
    private static function _hx_zmq_ZMQ_POLLOUT():Int {return untyped __php__('ZMQ::POLL_OUT');}
    private static function _hx_zmq_ZMQ_POLLERR():Int {
        throw new ZMQException(ENOTSUP);
        return null;
    }
    private static function _hx_zmq_DONTWAIT():Int {return untyped __php__('ZMQ::MODE_NOBLOCK');}
    private static function _hx_zmq_SNDMORE():Int {return untyped __php__('ZMQ::MODE_SNDMORE');}
    
    // Use the ZMQ::ERR_ENOTSUP for any Exxxx codes not supported by php-zmq binding
    private static inline function _hx_zmq_EINVAL():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_ENOTSUP():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_EPROTONOSUPPORT():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_EAGAIN():Int {return untyped __php__('ZMQ::ERR_EAGAIN');}
    private static inline function _hx_zmq_ENOMEM():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_ENODEV():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_ENOBUFS():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_ENETDOWN():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_EADDRINUSE():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_EADDRNOTAVAIL():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_ECONNREFUSED():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_EINPROGRESS():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_EMTHREAD():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_EFSM():Int {return untyped __php__('ZMQ::ERR_EFSM');}
    private static inline function _hx_zmq_ENOCOMPATPROTO():Int {return untyped __php__('ZMQ::ERR_ENOTSUP');}
    private static inline function _hx_zmq_ETERM():Int {return untyped __php__('ZMQ::ERR_ETERM');}
        
  	#end
}

