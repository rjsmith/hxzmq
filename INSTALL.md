hxzmq Installation Instructions
===============================

## Dependencies

To just build or just use hxzmq in a haXe project, you will need a working 0MQ library installation, that is either copied into the same folder as the haXe program executable, or on your computer's executable path.
There are [lots of instructions on the zeromq website][1].

To actually build hxzmq from source, you will need some additional installation steps:
### HXCPP (all OS, neko and cpp targets)
The hxzmq repository uses the hxcpp build tool to compile hxzmq.ndll from source on all target operating systems, for neko and cpp -based applications:.

1.  You need to install the full hxcpp package on your development machine:
        haxelib install hxcpp
2.  For Linux / neko, add the path to the hxcpp/bin/Linux folder to your machine's executable PATH:
        HAXE_HOME=/usr/lib/haxe
        PATH=$PATH:$HAXE_HOME/lib/hxcpp/2,07,0/bin/Linux
    This prevents the CFFI loader from reporting "Could not link plugin to process"    

### ZeroMQ (Windows)
To build hxzmq on Windows, you need to:

1.  Build 'release' libzmq in MSVC2008 (or later), and then copy the created libzmq.lib file into the hxzmq/lib folder (see the reference to this path in the `<set name="LIB_DIR" value="-libpath:lib" if="windows"/>` line in the hxzmq/build.xml HXCPP build tool configuration file.  This file appears necessary for the MSVC linker to compile against the libzmq.dll.
2.  Edit the hxzmq/build.xml file to change the paths to your libzmq installation include and src folders eg:
        <compilerflag value = "-IC:\zeromq\zeromq-2.1.6\include" if="windows"/>
        <compilerflag value = "-IC:\zeromq\zeromq-2.1.6\src" if="windows"/>
    Both of these are necessary to build hxzmq on Windows, as it refers to header files contained in the libzmq distribution.    
Note that if you build the debug target libzmq MSVC project, you may encounter errors related to a missing MSVCR100D.dll (debug c++ runtime).

## PHP-ZMQ (PHP target)
The haXe classes in the org.zeromq namespace (/org/zeromq in the project structure) include php - specific code to integrate the haXe ZMQ API with the [php-zmq PHP zeroMQ binding][3].

To use this, install the php-zmq extension following the instructions documented in the php-zmq project.  Then compile your PHP - targetted haXe application code including the hxzmq library. Instead of using the hxzmq.ndll C wrapper, the haXe zeroMQ code redirects to the php-zmq class methods.

## hxzmq Library Installation using haxelib

To be able to just use hxzmq to build 0MQ messaging into new haXe applications, 
without modifying the or re-building hxzmq from source, you need:

1.  Install the current hxzmq package using the haXe haxelib tool:
        haxelib install hxzmq

2.  To build your application including the hxzmq project, 
    include the hxzmq library in your hxml haXe compilation file:
        -lib hxzmq
        
3.  *(For neko and cpp targetted applications only)* To run your target executable, your system will need to reach the hxzmq.ndll library file
    and the libzmq.dll 0MQ library file.  Add both paths to your environment executable PATH variable or copy into a standard library path directory if not in one already (e.g. /usr/lib in linux), 
    or copy both files into the same folder as your newly-minted haXe executable 
    (e.g. either a neko .n or cpp executable).

## Building hxzmq.ndll From Source
In this repository, hxzmq is built using the hxcpp build tool (see [Building Using the HXCPP Build-tool][2]).
This is a cross-platform tool (written in haXe, of course!) that is designed to help build cffi ndll library files.
It is also used internally by the haXe compiler when building for the cpp target language platform.

The HXCCP build tool uses a single configuration file, `build.xml` in the top-level folder in the hxzmq repository.
There are some platform-specific edits you will need to make to configure to your exact system setup (see Dependencies section above).

To compile hxzmq via the hxcpp build tool, execute the following commands for each platform, from the hxzmq top-level folder:

*   (for MacOS 64bit):
        haxelib run hxcpp build.xml -DHXCPP_M64
*   (for Linux 32bit):
        haxelib run hxcpp build.xml
*   (for Windows):
        haxelib run hxcpp build.xml

        

## To build and run the Unit Tests

hxzmq includes a suite of unit tests that cover most of the 0MQ API.
The source code for these is in the org/zeromq/tests folder in this repository.
To build targets from these tests, `cd test` and then invoke the `haxe` command with the hxml build file appropriate to your platform, eg::
    haxe buildMac64.hxml
or
    haxe buildWindows.hxml
or
    haxe buildLinux.hxml
    
These create debug - enabled target cpp, neko and php executables in the test/out-cpp/... , test/out-neko/... and test/out-php/... folders.
Then to run the test executables:

For neko and cpp:
1.  Navigate to the folder holding the test executable (cpp or neko, OS-specific), 
2.  Ensure that the hxzmq.ndll and libzmq.dll files are on your executable path (or copied into this folder)
3.  Run the program

e.g, to build and run the cpp unit test target executable on Mac64:
    cd test
    haxe buildMac64.hxml
    cd out-cpp/Mac64
    ./TestAll-debug

For php:
1.  Navigate to the folder holding the test index.php file. 
2.  Ensure that the php-zmq extension is available (run `php -m` and look for `zmq`)
3.  Run the program

e.g, to build and run the php unit test target executable on Mac64:
    cd test
    haxe buildMac64.hxml
    cd out-php/Mac64
    php -f index.php


You should see output similar to:
    Class: org.zeromq.test.TestVersion TestVersion.hx:50: version_full:20107
    ..
    Class: org.zeromq.test.TestContext ......
    Class: org.zeromq.test.TestError ..
    Class: org.zeromq.test.TestSocket .......
    Class: org.zeromq.test.TestPubSub ..
    Class: org.zeromq.test.TestMultiPartMessage .
    Class: org.zeromq.test.TestReqRep ...
    Class: org.zeromq.test.TestPoller ....
    Class: org.zeromq.test.TestZMQRemoting ..
    Class: org.zeromq.test.TestZContext .....
    Class: org.zeromq.test.TestZSocket ..
    Class: org.zeromq.test.TestZFrame ..
    Class: org.zeromq.test.TestZMsg .....
    Class: org.zeromq.test.TestZLoop I: zloop: register timer delay=10 times=1
    I: zloop: register socket poller ZMQ_PAIR
    I: ZLoop: polling for 9 msec
    I: zloop: call timer handler
    I: ZLoop: polling for 3600000 msec
    I: zloop: call socket handler
    .

    OK 44 tests, 0 failed, 44 success


[1]: http://www.zeromq.org/intro:get-the-software "ZeroMQ installation"
[2]: http://haxe.org/doc/cpp/ffi "HXCPP Build Tool"
[3]: http://github.com/mkoppanen/php-zmq
