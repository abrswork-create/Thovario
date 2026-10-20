import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thovario/data/database/app_database.dart';
import 'package:thovario/data/database/migrations.dart';
import 'package:thovario/data/models/thought.dart';
import 'package:thovario/data/repositories/thought_repository.dart';
import 'package:thovario/data/services/database_service.dart';

void main() {
  // Setup sqflite FFI for running tests without an actual mobile device
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late AppDatabase appDatabase;
  late DatabaseService databaseService;
  late ThoughtRepository repository;

  setUp(() async {
    // Open in-memory temporary database
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseMigrations.currentVersion,
        onCreate: DatabaseMigrations.onCreate,
      ),
    );
    appDatabase = AppDatabase(database: db);
    databaseService = DatabaseService(appDatabase: appDatabase);
    repository = ThoughtRepository(databaseService: databaseService);
  });

  tearDown(() async {
    await db.close();
  });

  group('Database & ThoughtRepository Integration Tests', () {
    test('Empty database returns empty list without errors', () async {
      final thoughts = await repository.getThoughts();
      expect(thoughts, isEmpty);

      final favorites = await repository.getFavorites();
      expect(favorites, isEmpty);

      final searchResults = await repository.searchThoughts('nonexistent');
      expect(searchResults, isEmpty);
    });

    test('Creates and reads a thought entry', () async {
      final now = DateTime.now();
      final thought = Thought(
        id: 't-1',
        title: 'Morning Silence',
        content: 'Watching the dawn quietly before the world wakes.',
        createdAt: now,
        updatedAt: now,
        isFavorite: false,
      );

      await repository.saveThought(thought);

      final fetched = await repository.getThoughtById('t-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Morning Silence');
      expect(
        fetched.content,
        'Watching the dawn quietly before the world wakes.',
      );
      expect(fetched.isFavorite, false);
    });

    test('Updates an existing thought entry', () async {
      final created = DateTime(2026, 10, 19, 10, 0);
      final thought = Thought(
        id: 't-2',
        title: 'Initial Note',
        content: 'Draft content.',
        createdAt: created,
        updatedAt: created,
        isFavorite: false,
      );

      await repository.saveThought(thought);

      final updated = thought.copyWith(
        title: 'Polished Title',
        content: 'Polished deep reflections.',
        updatedAt: DateTime(2026, 10, 19, 11, 0),
      );

      await repository.saveThought(updated);

      final result = await repository.getThoughtById('t-2');
      expect(result!.title, 'Polished Title');
      expect(result.content, 'Polished deep reflections.');
      expect(result.createdAt, created);
      expect(result.updatedAt, DateTime(2026, 10, 19, 11, 0));
    });

    test('Toggles favorite state correctly', () async {
      final now = DateTime.now();
      final thought = Thought(
        id: 't-3',
        title: 'Starry Thought',
        content: 'To keep close.',
        createdAt: now,
        updatedAt: now,
        isFavorite: false,
      );

      await repository.saveThought(thought);

      // Favorite it
      await repository.toggleFavorite('t-3', false);
      var fetched = await repository.getThoughtById('t-3');
      expect(fetched!.isFavorite, true);

      var favorites = await repository.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, 't-3');

      // Unfavorite it
      await repository.toggleFavorite('t-3', true);
      fetched = await repository.getThoughtById('t-3');
      expect(fetched!.isFavorite, false);

      favorites = await repository.getFavorites();
      expect(favorites, isEmpty);
    });

    test('Deletes a single thought by ID', () async {
      final now = DateTime.now();
      final t1 = Thought(
        id: 'del-1',
        content: 'One',
        createdAt: now,
        updatedAt: now,
      );
      final t2 = Thought(
        id: 'del-2',
        content: 'Two',
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveThought(t1);
      await repository.saveThought(t2);

      expect((await repository.getThoughts()).length, 2);

      await repository.deleteThought('del-1');

      final remaining = await repository.getThoughts();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'del-2');
      expect(await repository.getThoughtById('del-1'), isNull);
    });

    test('Deletes all thoughts when requested', () async {
      final now = DateTime.now();
      await repository.saveThought(
        Thought(id: 'a', content: 'A', createdAt: now, updatedAt: now),
      );
      await repository.saveThought(
        Thought(id: 'b', content: 'B', createdAt: now, updatedAt: now),
      );

      expect((await repository.getThoughts()).length, 2);

      await repository.deleteAllThoughts();

      expect(await repository.getThoughts(), isEmpty);
    });

    test('Searches by title and content', () async {
      final now = DateTime.now();
      await repository.saveThought(
        Thought(
          id: 's-1',
          title: 'Ocean Waves',
          content: 'Quiet breeze.',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.saveThought(
        Thought(
          id: 's-2',
          title: 'Night Sky',
          content: 'Stars and waves of peace.',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.saveThought(
        Thought(
          id: 's-3',
          title: 'Mountain Hike',
          content: 'High altitude quiet.',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Search by word in title
      final titleSearch = await repository.searchThoughts('Ocean');
      expect(titleSearch.length, 1);
      expect(titleSearch.first.id, 's-1');

      // Search by word in content
      final contentSearch = await repository.searchThoughts('altitude');
      expect(contentSearch.length, 1);
      expect(contentSearch.first.id, 's-3');

      // Search matching both
      final multiSearch = await repository.searchThoughts('waves');
      expect(multiSearch.length, 2);
    });

    test('Sorts by newest first and oldest first', () async {
      final t1 = Thought(
        id: 'first',
        content: 'Created first',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final t2 = Thought(
        id: 'second',
        content: 'Created second',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      );
      final t3 = Thought(
        id: 'third',
        content: 'Created third',
        createdAt: DateTime(2026, 12, 1),
        updatedAt: DateTime(2026, 12, 1),
      );

      await repository.saveThought(t2);
      await repository.saveThought(t1);
      await repository.saveThought(t3);

      final newest = await repository.getThoughts(newestFirst: true);
      expect(newest.map((e) => e.id).toList(), ['third', 'second', 'first']);

      final oldest = await repository.getThoughts(newestFirst: false);
      expect(oldest.map((e) => e.id).toList(), ['first', 'second', 'third']);
    });
  });
}
