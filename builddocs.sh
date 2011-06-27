#!/bin/bash

echo "** Build documentation:"
haxe buildDocs.hxml

chxdoc -o docs --developer=false --includeOnly=org.zeromq.* docs/cpp.xml,cpp

rm -r tmp
