import 'package:flutter/material.dart';

void main() {
  final text = 'hello world';
  final keywords = ['world', 'wo'];
  
  final activeKeywords =
        keywords.where((k) => k.trim().isNotEmpty).toList()
          ..sort((a, b) => b.length.compareTo(a.length));
          
  final pattern = activeKeywords
        .map((k) => RegExp.escape(k.trim()))
        .join('|');
  final regex = RegExp(pattern, caseSensitive: false);
  
  print('Regex: \$regex');
  
  for (final match in regex.allMatches(text)) {
    print('Match: \${text.substring(match.start, match.end)}');
  }
}
