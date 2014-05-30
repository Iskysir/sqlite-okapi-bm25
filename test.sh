#!/bin/sh
# test.sh
# Author: Josh Wilson 2014-05-30

# This test script is for MacOSX
# See http://www.sqlite.org/loadext.html for more info on how to compile an extension for your target OS

gcc -g -fPIC -dynamiclib -Isqlite3 -arch i386 -o okapi_bm25.dylib okapi_bm25.c

 sqlite3 -echo -column -header -cmd ".load okapi_bm25" test/test.db "SELECT okapi_bm25f(matchinfo(songs, 'pcxnals')) AS rank, snippet(songs, '', '', '...', -1, -10) as snip FROM songs WHERE songs MATCH \"Bob* OR Dylan*\" ORDER BY rank DESC;"