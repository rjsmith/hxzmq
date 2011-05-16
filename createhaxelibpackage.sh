#!/bin/bash

echo "Zipping up hxzmq into haxelib - ready package"
cd ..
rm hx*zip
zip -r -x@hxzmq/zipexclude.lst hxzmq.zip hxzmq

echo "Running haxelib test hxzmq.zip to create test package in haxe lib folder"
haxelib test hxzmq.zip

echo "Done."
