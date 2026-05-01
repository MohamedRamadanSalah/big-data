import sqlite3
c = sqlite3.connect('assets/search_data.db').cursor()
c.execute("SELECT title FROM pages WHERE pages MATCH '\"med\"*' LIMIT 5")
for row in c.fetchall():
    print(row)
