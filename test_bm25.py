import sqlite3
c = sqlite3.connect('assets/search_data.db').cursor()
c.execute("SELECT title, bm25(pages, 0.0, 100.0, 1.0) FROM pages WHERE pages MATCH '\"med\"*' ORDER BY bm25(pages, 0.0, 100.0, 1.0) ASC, LENGTH(title) ASC LIMIT 5")
for row in c.fetchall():
    print(row)
