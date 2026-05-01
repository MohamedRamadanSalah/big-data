import sqlite3
c = sqlite3.connect('assets/search_data.db').cursor()
c.execute("SELECT title, LENGTH(title) FROM pages WHERE pages MATCH 'med*' ORDER BY LENGTH(title) ASC LIMIT 20")
for row in c.fetchall():
    print(repr(row))
