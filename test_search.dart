import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  var factory = databaseFactoryFfi;
  
  print('Opening database...');
  final dbPath = 'assets/search_data.db';
  if (!File(dbPath).existsSync()) {
    print('DB not found at $dbPath');
    return;
  }
  
  final db = await factory.openDatabase(dbPath, options: OpenDatabaseOptions(readOnly: true));
  
  print('Running FTS5 search for "flutter ui"...');
  final stopwatch = Stopwatch()..start();
  
  final query = '"flutter"* AND "ui"*';
  final limit = 50;
  final snippetChars = 600;
  
  try {
    final rows = await db.rawQuery(
      '''
      SELECT 
        url, 
        title, 
        SUBSTR(content, 1, $snippetChars) AS snippet 
      FROM pages 
      WHERE pages MATCH ? 
      LIMIT ?
      ''',
      [query, limit],
    );
    
    stopwatch.stop();
    print('Found ${rows.length} results in ${stopwatch.elapsedMilliseconds} ms!');
    
    if (rows.isNotEmpty) {
      print('--- First result ---');
      print('Title: ${rows.first['title']}');
      print('URL: ${rows.first['url']}');
      print('Snippet: ${rows.first['snippet'].toString().replaceAll(RegExp(r'\n+'), ' ').substring(0, 100)}...');
    }
    
  } catch (e) {
    print('Error: $e');
  } finally {
    await db.close();
  }
}
