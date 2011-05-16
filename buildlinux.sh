#!/bin/bash

echo "** Build hxzmq.ndll:"
haxelib run hxcpp build.xml 

echo "** Build Haxe Unit Tests:"
cd test
/usr/bin/haxe buildLinux.hxml

echo "** Build Haxe ZeroMQ Guide programs:"
cd ../guide
/usr/bin/haxe buildLinux.hxml

echo "** Copying hxzmq.ndll:"
cd ..
cp ndll/Linux/hxzmq.ndll test/out-cpp/Linux
cp ndll/Linux/hxzmq.ndll test/out-neko/Linux
cp ndll/Linux/hxzmq.ndll guide/out-cpp/Linux
cp ndll/Linux/hxzmq.ndll guide/out-neko/Linux

echo "** Running CPP executables:"
cd test/out-cpp/Linux
./TestAll-debug


