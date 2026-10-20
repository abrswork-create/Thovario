import 'package:flutter_test/flutter_test.dart';
import 'package:thovario/data/models/thought.dart';

void main() {
  group('Thought Model Tests', () {
    final testDate = DateTime.parse('2026-10-19T14:30:00.000Z');

    test('Serializes to Map with correct database columns and types', () {
      final thought = Thought(
        id: 'test-uuid-1',
        title: 'Silent Reflection',
        content: 'Some things do not need to be sent.',
        createdAt: testDate,
        updatedAt: testDate,
        isFavorite: true,
      );

      final map = thought.toMap();

      expect(map['id'], 'test-uuid-1');
      expect(map['title'], 'Silent Reflection');
      expect(map['content'], 'Some things do not need to be sent.');
      expect(map['created_at'], '2026-10-19T14:30:00.000Z');
      expect(map['updated_at'], '2026-10-19T14:30:00.000Z');
      expect(map['is_favorite'], 1);
    });

    test('Deserializes from Map correctly', () {
      final map = {
        'id': 'test-uuid-2',
        'title': 'An Unsent Note',
        'content': 'Words kept safe in the quiet.',
        'created_at': '2026-10-19T14:30:00.000Z',
        'updated_at': '2026-10-19T14:30:00.000Z',
        'is_favorite': 0,
      };

      final thought = Thought.fromMap(map);

      expect(thought.id, 'test-uuid-2');
      expect(thought.title, 'An Unsent Note');
      expect(thought.content, 'Words kept safe in the quiet.');
      expect(thought.createdAt, testDate);
      expect(thought.updatedAt, testDate);
      expect(thought.isFavorite, false);
    });

    test('Handles null title gracefully by defaulting to empty string', () {
      final map = {
        'id': 'test-uuid-3',
        'title': null,
        'content': 'Just thoughts without a title.',
        'created_at': '2026-10-19T14:30:00.000Z',
        'updated_at': '2026-10-19T14:30:00.000Z',
        'is_favorite': 1,
      };

      final thought = Thought.fromMap(map);
      expect(thought.title, '');
      expect(thought.isFavorite, true);
    });

    test('copyWith produces updated copies with identity preservation', () {
      final original = Thought(
        id: '1',
        title: 'Original Title',
        content: 'Original Content',
        createdAt: testDate,
        updatedAt: testDate,
        isFavorite: false,
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isFavorite: true,
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Updated Title');
      expect(updated.content, 'Original Content');
      expect(updated.isFavorite, true);
      expect(updated.createdAt, testDate);
    });

    test('Value equality works properly', () {
      final t1 = Thought(
        id: '1',
        title: 'Title',
        content: 'Content',
        createdAt: testDate,
        updatedAt: testDate,
        isFavorite: false,
      );

      final t2 = Thought(
        id: '1',
        title: 'Title',
        content: 'Content',
        createdAt: testDate,
        updatedAt: testDate,
        isFavorite: false,
      );

      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
    });
  });
}
