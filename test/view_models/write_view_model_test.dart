import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thovario/data/database/app_database.dart';
import 'package:thovario/data/database/migrations.dart';
import 'package:thovario/data/models/thought.dart';
import 'package:thovario/data/repositories/thought_repository.dart';
import 'package:thovario/data/services/database_service.dart';
import 'package:thovario/features/write/view_models/write_view_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ThoughtRepository repository;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseMigrations.currentVersion,
        onCreate: DatabaseMigrations.onCreate,
      ),
    );
    final appDb = AppDatabase(database: db);
    repository = ThoughtRepository(
      databaseService: DatabaseService(appDatabase: appDb),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('WriteViewModel & Unsaved-Changes Tests', () {
    test('Initial empty state cannot be saved and has no unsaved changes', () {
      final vm = WriteViewModel(thoughtRepository: repository);

      expect(vm.canSave, isFalse);
      expect(vm.hasUnsavedChanges, isFalse);
      expect(vm.isEditing, isFalse);
    });

    test(
      'Typing in title or content triggers hasUnsavedChanges and enables canSave',
      () {
        final vm = WriteViewModel(thoughtRepository: repository);

        vm.contentController.text = 'A silent feeling';

        expect(vm.canSave, isTrue);
        expect(vm.hasUnsavedChanges, isTrue);

        vm.contentController.text = '   ';
        expect(vm.canSave, isFalse);
        expect(vm.hasUnsavedChanges, isFalse);
      },
    );

    test('Saving new thought persists to repository', () async {
      final vm = WriteViewModel(thoughtRepository: repository);

      vm.titleController.text = 'Night Whisper';
      vm.contentController.text = 'Words I kept to myself.';

      final saved = await vm.saveThought();
      expect(saved, isTrue);

      final thoughts = await repository.getThoughts();
      expect(thoughts.length, 1);
      expect(thoughts.first.title, 'Night Whisper');
      expect(thoughts.first.content, 'Words I kept to myself.');
    });

    test('Editing existing thought detects modifications correctly', () {
      final now = DateTime.now();
      final existing = Thought(
        id: 'orig-1',
        title: 'Original Title',
        content: 'Original Content',
        createdAt: now,
        updatedAt: now,
      );

      final vm = WriteViewModel(
        thoughtRepository: repository,
        existingThought: existing,
      );

      expect(vm.isEditing, isTrue);
      expect(vm.hasUnsavedChanges, isFalse);

      vm.contentController.text = 'Modified Content';
      expect(vm.hasUnsavedChanges, isTrue);

      // Revert back
      vm.contentController.text = 'Original Content';
      expect(vm.hasUnsavedChanges, isFalse);
    });
  });
}
