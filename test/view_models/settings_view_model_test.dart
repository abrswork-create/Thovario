import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thovario/core/constants/storage_keys.dart';
import 'package:thovario/data/database/app_database.dart';
import 'package:thovario/data/database/migrations.dart';
import 'package:thovario/data/models/thought.dart';
import 'package:thovario/data/repositories/thought_repository.dart';
import 'package:thovario/data/services/database_service.dart';
import 'package:thovario/features/settings/view_models/settings_view_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ThoughtRepository repository;
  late SharedPreferences prefs;
  late SettingsViewModel viewModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

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
    viewModel = SettingsViewModel(prefs: prefs, thoughtRepository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsViewModel & Preferences Tests', () {
    test('Default theme is dark', () {
      expect(viewModel.themeMode, ThemeMode.dark);
    });

    test('Persists theme mode changes to SharedPreferences', () async {
      await viewModel.setThemeMode(ThemeMode.light);
      expect(viewModel.themeMode, ThemeMode.light);
      expect(prefs.getString(StorageKeys.themeMode), 'light');

      await viewModel.setThemeMode(ThemeMode.system);
      expect(viewModel.themeMode, ThemeMode.system);
      expect(prefs.getString(StorageKeys.themeMode), 'system');

      await viewModel.setThemeMode(ThemeMode.dark);
      expect(viewModel.themeMode, ThemeMode.dark);
      expect(prefs.getString(StorageKeys.themeMode), 'dark');
    });

    test('Loads previously saved theme from SharedPreferences', () async {
      await prefs.setString(StorageKeys.themeMode, 'light');
      final newViewModel = SettingsViewModel(
        prefs: prefs,
        thoughtRepository: repository,
      );
      expect(newViewModel.themeMode, ThemeMode.light);
    });

    test('Onboarding persistence flag sets and reads properly', () async {
      expect(prefs.getBool(StorageKeys.hasCompletedOnboarding), isNull);
      await prefs.setBool(StorageKeys.hasCompletedOnboarding, true);
      expect(prefs.getBool(StorageKeys.hasCompletedOnboarding), true);
    });

    test('Delete all thoughts clears records and notifies state', () async {
      final now = DateTime.now();
      await repository.saveThought(
        Thought(id: '1', content: 'test', createdAt: now, updatedAt: now),
      );
      expect((await repository.getThoughts()).length, 1);

      await viewModel.deleteAllThoughts();
      expect((await repository.getThoughts()), isEmpty);
    });
  });
}
