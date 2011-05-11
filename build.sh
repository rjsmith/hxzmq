#!/bin/bash

echo "** Build hxzmq.ndll:"
haxelib run hxcpp build.xml -DHXCPP_M64

echo "** Build Haxe Unit Tests:"
cd test
/usr/bin/haxe buildMac64.hxml

echo "** Build Haxe ZeroMQ Guide programs:"
cd ../guide
/usr/bin/haxe buildMac64.hxml

echo "** Copying hxzmq.ndll:"
cd ..
cp bin/ndll/Mac64/hxzmq.ndll test/out-cpp/Mac64
cp bin/ndll/Mac64/hxzmq.ndll test/out-neko/Mac64
cp bin/ndll/Mac64/hxzmq.ndll guide/out-cpp/Mac64

echo "** Running CPP executables:"
cd test/out-cpp/Mac64
./TestAll-debug


