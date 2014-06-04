SELECT * FROM songs WHERE song_search_text LIKE "%Bob%" OR song_search_text LIKE "%Dylan%";

SELECT okapi_bm25(matchinfo(songs, 'pcxnal'), 1) AS rank, snippet(songs, '', '', '...', -1, -10) as snip FROM songs WHERE songs MATCH "Bob* OR Dylan*" ORDER BY rank DESC;

SELECT okapi_bm25f(matchinfo(songs, 'pcxnal')) AS rank, snippet(songs, '', '', '...', -1, -10) as snip FROM songs WHERE songs MATCH "Bob* OR Dylan*" ORDER BY rank DESC;
SELECT okapi_bm25f_kb(matchinfo(songs, 'pcxnal'), 1.20, 0.75) AS rank, snippet(songs, '', '', '...', -1, -10) as snip FROM songs WHERE songs MATCH "Bob* OR Dylan*" ORDER BY rank DESC;

--these queries put a zero weighting on matches in the `id` column
SELECT okapi_bm25f(matchinfo(songs, 'pcxnal'), 0.0, 1.0) AS rank, snippet(songs, '', '', '...', -1, -10) as snip FROM songs WHERE songs MATCH "Bob* OR Dylan*" ORDER BY rank DESC;
SELECT okapi_bm25f_kb(matchinfo(songs, 'pcxnal'), 1.20, 0.75, 0.0, 1.0) AS rank, snippet(songs, '', '', '...', -1, -10) as snip FROM songs WHERE songs MATCH "Bob* OR Dylan*" ORDER BY rank DESC;
