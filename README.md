hxzmq - haXe Language Bindings for ZeroMQ
=========================================

Welcome to hxzmq, [haXe language bindings] [2] for the iMatix [ZeroMQ messaging library] [3].  0MQ is a lightweight and fast messaging implementation.

By Richard Smith [RSBA Technology Ltd] [1]


## Introduction
This repository provides C++ binding code that wraps the libzmq library API to create a Neko DLL file, hxzmq.ndll.  The ndll is then accessed via the hxzmq org.zeromq package to expose the 0MQ API to haXe application code targetted at C++ or nekovm platforms.

Also included is wrapper code around the [existing PHP ZeroMQ binding] [12], enabling haXe programs compiled for the PHP environment can slso make use of zeroMQ socket technology.
### Background & Rationale
haXe enables applications to be written in a single unified programming language that can then be executed on any combination of an ever-growing number of [target language platforms.] [6].  It is quite possible to write back-end server code targetted at php or C++, with a rich internet application Flash or javascript front-end, plus an iPhone application (via the C++ target), all using a single shared haXe codebase.  Code written using non-target specific APIs can be automatically re-used on any of these platforms, such as an application's internal domain model or framework code.  Conditional compilation, together with many target - specific APIs contained in the [haXe standard library] [7], provides the opportunity to access platform-specific features, giving the best of both worlds.  Most of the target platforms also support extending the standard capabilities by use of externs and Foreign Function Interface mechanisms; an ability which has been used to write hxzmq.  haXe is an [open source project] [7]. 

0MQ is a relatively recent entrant into the messaging layer software space, conceived as a low-level, cross-platform but highly - performant messaging library that can replace direct use of in-process and tcp sockets etc with a message-orientated API.  It implements a number of well-defined message patterns (e.g. Request-Reply, Publish-Subscribe) that allow very complex distributed system architectures to be built from simple parts.  0MQ is maintained as an [open source project] [8] by iMatix.

hxzmq has been written to allow the author (and anyone else who might be interested) to explore and experiment what improvements in software design practise can be made when a cross-platform language is coupled with a highly performant cross-platform messaging layer.   
### haXe Code Example

Client:

	package ;
	import haxe.io.Bytes;
	import org.zeromq.ZMQ;
	import org.zeromq.ZMQContext;
	import org.zeromq.ZMQSocket;

	/**
	 * Hello World client in Haxe.
	 */
	class HelloWorldClient 
	{
		public static function main() {
			var context:ZMQContext = ZMQContext.instance();
			var socket:ZMQSocket = context.socket(ZMQ_REQ);
			socket.connect ("tcp://localhost:5556");
			for (i in 0...10) {
				var requestString = "Hello ";
				socket.sendMsg(Bytes.ofString(requestString));
				var msg:Bytes = socket.recvMsg();
				trace ("Received reply " + i + ": [" + msg.toString() + "]");				
			}
			socket.close();
			context.term();
		}
	}

Server:

    package ;
	import haxe.io.Bytes;
	import org.zeromq.ZMQ;
	import org.zeromq.ZMQContext;
	import org.zeromq.ZMQException;
	import org.zeromq.ZMQSocket;

	/**
	 * Hello World server in Haxe
	 * Binds REP to tcp://*:5556
	 * Expects "Hello" from client, replies with "World"
	 * 
	 */
	class HelloWorldServer 
	{
		public static function main() {			
			var context:ZMQContext = ZMQContext.instance();
			var responder:ZMQSocket = context.socket(ZMQ_REP);
			responder.bind("tcp://*:5556");			
			while (true) {
				var request:Bytes = responder.recvMsg();
				// Do some work
				Sys.sleep(1);
				// Send reply back to client
				responder.sendMsg(Bytes.ofString("World"));
			}
			responder.close();
			context.term();	
		}
	}

## Contents

Key files and folders contained in this repository:

*   *build.xml*

    XML compilation configuration file used by the hxcpp cross-platform ndll build tool to compile & build the hxzmq.ndll library.  See INSTALL.md for further details.
	
*   *buildmac64.sh*

    Mac OSX 64bit build shell script that builds hxzmq.ndll, unit test and guide programs
	
*   *buildlinux.sh*

    Linux 32bit build shell script that builds hxzmq.ndll, unit test and guide programs
    
*   *build.bat*

    Windows script file that builds hxzmq.ndll, unit test and guide programs
	
*   */src*

    The C++ code that wraps the libzmq C library in [hxcpp CFFI] [10] calls, which exposes it to the haXe layer. Compiles into the hxzmq.ndll library.
	
*   */org/zeromq*

    The haXe code that invokes the native functions defined in hxzmq.ndll. Provides the core API used by haXe applications (ZMQxxxxx.hx files) and higher-level API classes (Zxxxx.hx files).
    
*   */org/zeromq/remoting*
    
    haXe classes that implement a haXe remoting wrapper on top of ZMQSocket objects. 
    
*   */org/zeromq/test*

    Unit tests for the org.zeromq package.  Main program invoked from the TestAll.hx class.
	
*   */org/zeromq/guide*

    haXe implementations of some code examples included in the [0MQ Guide] [11]. Can be compiled separately, or via the menu class, Run.hx.

*   */test*

    Contains build hxml files for compiling the unit tests on different platforms.
	
*   */guide*

    Contains build hxml files for compiling the 0MQ Guide code examples on different platforms
	
*   *ndll/*

    Contains pre-built ndll files for different platforms
    
*   *doc/*

    Contains generated HTML documentation for the ZMQxxx.hx and Zxxx.hx class files.
	
## Versions

The current release of hxzmq is 1.2.0, compatable with libzmq-2.1.4 or any later 2.1.x version.  The latest released hxzmq package shall also be available in the [haxelib repository] [4], accessable via the [haxelib tool] [5] which is included in the standard haXe distribution.

This version of hxzmq has also been tested against [php-zmq v0.7.0] [13] 

## Building and Installation

If you are a haXe user who just wants to start using 0MQ and hxzmq in your projects, make sure libzmq.dll is available on your system's PATH setting, and then simply install the latest hxzmq package available from the haXe repository, using the haxelib tool:

    haxelib install hxzmq
	
Please refer to the separate INSTALL.md file in this distribution for details on how to build and install hxzmq.ndll from source.

## Copying

Free use of this software is granted under the terms of the GNU Lesser General
Public License (LGPL). For details see the files `COPYING.LESSER`
included with the hxzmq distribution.

[1]: http://rsbatechnology.co.uk "RSBA Technology Ltd"
[2]: http://haxe.org "haXe"
[3]: http://zeromq.org "ZeroMQ"
[4]: http://lib.haxe.org "haXelib repository"
[5]: http://haxe.org/com/haxelib "haXelib"
[6]: http://haxe.org/doc/features "haXe Features"
[7]: http://code.google.com/p/haxe "haXe source code repository"
[8]: https://github.com/zeromq/libzmq "libzmq source code repository"
[9]: http://www.imatix.com/ "iMatix Corporation"
[10]: http://haxe.org/doc/cpp/ffi "C++ FC Foreign Function Interface"
[11]: http://zguide.zeromq.org/ "0MQ Guide"
[12]: http://github.com/mkoppanen/php-zmq
[13]: http://github.com/mkoppanen/php-zmq/blob/0.7.0



