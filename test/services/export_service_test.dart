import 'package:flutter_test/flutter_test.dart';
import 'package:thovario/data/models/thought.dart';
import 'package:thovario/data/services/export_service.dart';

void main() {
  group('ExportService Tests', () {
    test('Formats thoughts cleanly to Markdown format', () {
      final date = DateTime(2026, 10, 19, 14, 0);
      final thoughts = [
        Thought(
          id: '1',
          title: 'A Silent Letter',
          content: 'I never sent this message, but it gave me closure.',
          createdAt: date,
          updatedAt: date,
          isFavorite: true,
        ),
        Thought(
          id: '2',
          title: '',
          content: 'An untitled midnight reflection.',
          createdAt: date,
          updatedAt: date,
          isFavorite: false,
        ),
      ];

      final markdown = ExportService.formatAsMarkdown(thoughts);

      expect(markdown, contains('# Thovario Journal Export'));
      expect(markdown, contains('2 entries'));
      expect(markdown, contains('## A Silent Letter'));
      expect(markdown, contains('★ Favorite'));
      expect(
        markdown,
        contains('I never sent this message, but it gave me closure.'),
      );
      expect(markdown, contains('## Untitled Thought'));
      expect(markdown, contains('An untitled midnight reflection.'));
    });
  });
}
