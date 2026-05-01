import sqlite3
import time

db_path = 'assets/search_data.db'

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    start_time = time.time()
    
    query = '"medicine"* AND "portal"*'
    cursor.execute('''
        SELECT url, title, SUBSTR(content, 1, 600) AS snippet 
        FROM pages 
        WHERE pages MATCH ? 
        LIMIT 5
    ''', (query,))
    
    results = cursor.fetchall()
    elapsed = (time.time() - start_time) * 1000
    
    print(f'\n========================================')
    print(f'✅ SEARCH SUCCESSFUL!')
    print(f'Query: {query}')
    print(f'Found {len(results)} results in {elapsed:.2f} milliseconds.')
    print(f'========================================\n')
    
    for i, res in enumerate(results):
        print(f'[{i+1}] {res[1]}')
        print(f'URL: {res[0]}')
        print(f'Snippet: {res[2][:100].replace(chr(10), " ")}...')
        print('-' * 40)
        
except Exception as e:
    print(f'Error: {e}')
finally:
    if 'conn' in locals():
        conn.close()
