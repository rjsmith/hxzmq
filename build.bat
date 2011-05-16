echo "** Build hxzmq.ndll on Windows:"
haxelib run hxcpp build.xml

echo "** Build Haxe Unit Tests:"
cd test
haxe buildWindows.hxml

echo "** Build Haxe ZeroMQ Guide programs:"
cd ../guide
haxe buildWindows.hxml

echo "** Copy hxzmq.ndll:"
cd ..
copy /Y ndll\Windows\hxzmq.ndll test\out-cpp\Windows
copy /Y ndll\Windows\hxzmq.ndll test\out-neko\Windows
copy /Y ndll\Windows\hxzmq.ndll guide\out-cpp\Windows
copy /Y ndll\Windows\hxzmq.ndll guide\out-neko\Windows
vi

rem echo "** Run CPP unit tests:"
rem cd test/out-cpp/Windows
rem TestAll-debug.exe

rem echo "** Run Neko unit tests:"
rem cd test/out-neko/Windows
rem neko TestAll.n