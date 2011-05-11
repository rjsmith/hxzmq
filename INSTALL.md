hxzmq Installation Instructions
===============================

## haxelib Installation

To be able to just use hxzmq to build 0MQ messaging into new haXe applications, without modifying the or re-building hxzmq from source, you need:

1.  Install the current hxzmq package using the haXe haxelib tool
    haxelib install hxzmq
2.  To build your application including the hxzmq project, include the hxzmq library in your hxml haXe compilation file:
    -lib hxzmq
3.  To run your target executable, your system will need to reach the hxzmq.ndll library file and the libzmq.dll 0MQ library file.  Add paths to both to your PATH environment variable, or copy both files into the same folder as your newly-minted haXe executable (e.g. either a neko .n or cpp executable).


