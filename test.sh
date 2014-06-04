#!/bin/sh
# test.sh
# Author: Josh Wilson 2014-05-30

# This test script is for MacOSX
# See http://www.sqlite.org/loadext.html for more info on how to compile an extension for your target OS
clear

#sqlite3 expects a 32bit architecture. Most modern machines are 64bit architecture so have to enforce 32bit.
gcc -g -fPIC -dynamiclib -Isqlite3 -arch i386 -o okapi_bm25.dylib okapi_bm25.c

sqlite3 -echo -column -header -cmd ".timer ON" -cmd ".load okapi_bm25" test/test.db < test/demo.sql