# Okapi BM25 for SQLite3

This SQLite extension creates a SQL function called `okapi_bm25` that returns the [Okapi BM25 ranking][o] for results of a full-text search. Okapi BM25 is a modern ranking function that calculates a score for each result based on its relevance to the search query. This extension only works with `MATCH` queries on [FTS4 tables][f].

[o]: https://en.wikipedia.org/wiki/Okapi_BM25
[f]: https://www.sqlite.org/fts3.html

## Installation

The extension must first be compiled from the source:

    $ make
    gcc -Wall -Werror -bundle -fPIC -Isqlite3 -o okapi_bm25.sqlext okapi_bm25.c

The compiled `okapi_bm25.sqlext` file can then be loaded as a SQLite extension. The way you do this depends on the language you're using. For example, the node-sqlite3 bindings have a special [extension API][l] you can call at the start of your program. If you're using SQLite from the console, you use the `.load` command to load the extension for the current session:

    sqlite> .load ./okapi_bm25.sqlext

[l]: https://github.com/mapbox/node-sqlite3/wiki/Extensions

## Usage

### okapi\_bm25(matchinfo, searchColumn \[, k1] \[, b])

The ranking function uses the built-in [matchinfo][m] function to obtain the data necessary to calculate the scores. A simple search query might look like this:

    SELECT title FROM documents
      WHERE title MATCH <query>
      ORDER BY okapi_bm25(matchinfo(documents, 'pcxnal'), 0) DESC

The `matchinfo` function **must** be called with `'pcxnal'` as the second argument. This argument defines the structure of the data given to the `okapi_bm25` function, which accepts the data in only one form. If the `matchinfo` function is called with a different second argument, the extension may provide incorrect results or fail to work entirely.

The `okapi_bm25` function only calculates the score for one column at a time. The `searchColumn` argument, provided as `0` in the example above, specifies the column it will use. The number is the index of the column within the FTS table. Here's a schema for the example above:

    CREATE VIRTUAL TABLE documents USING fts4(title, content);

In this schema, the `title` column is at index `0` because it is the first column listed. If the order were reversed, the correct index for `title` would be `1`.

The last two optional arguments, `k1` and `b`, are free parameters specific to the Okapi BM25 algorithm. The default values are `k1 = 1.2` and `b = 0.75`. You can tweak these for advanced optimization, but the defaults will probably work fine.

### okapi\_bm25f(matchinfo, \[column_weight, ...])

Using the example at the end of the [SQLite3 FTS3 documentation][a] this is how you should structure a call using this function where the title column is weighted 10x more important than the content column, although supplying no arguments to okapiBM25f() other than the matchinfo() will result in regular BM25 with all columns weighted as 1.0:


	SELECT title, snippet(documents) FROM documents JOIN ( 
		SELECT docid, okapi_bm25f(matchinfo(documents, 'pcxnal'), 10, 1) AS rank
		FROM documents
		WHERE documents MATCH <query>
		ORDER BY rank DESC 
		LIMIT 10 OFFSET 0
	) AS ranktable USING(docid)
	WHERE documents MATCH <query>
	ORDER BY ranktable.rank DESC
	
### okapi\_bm25f\_kb(matchinfo, k1, b, \[column_weight, ...])

Also provided is an implementation of Okapi BM25f that you can define the free variables `k1` and `b` followed optionally by a list of column weights. The example below is the same as before except showing the typical values for `k1` and `b` being passed through.


	SELECT title, snippet(documents) FROM documents JOIN ( 
		SELECT docid, okapi_bm25f_kb(matchinfo(documents, 'pcxnal'), 1.2, 0.75, 10, 1) AS rank
		FROM documents
		WHERE documents MATCH <query>
		ORDER BY rank DESC 
		LIMIT 10 OFFSET 0
	) AS ranktable USING(docid)
	WHERE documents MATCH <query>
	ORDER BY ranktable.rank DESC

[m]: https://www.sqlite.org/fts3.html#matchinfo
[a]: http://www.sqlite.org/fts3.html#appendix_a

## License

Okapi BM25 for SQLite3 is released under the [MIT License][i].

[i]: http://opensource.org/licenses/MIT
