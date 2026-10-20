import 'package:sqflite/sqflite.dart';

/// Database migration definitions and schema management.
class DatabaseMigrations {
  DatabaseMigrations._();

  static const int currentVersion = 1;

  static const String tableName = 'thoughts';

  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnIsFavorite = 'is_favorite';

  /// Initial database creation script (version 1)
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL DEFAULT '',
        $columnContent TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnIsFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Index for fast query by date and favorite
    await db.execute('''
      CREATE INDEX idx_thoughts_created_at ON $tableName ($columnCreatedAt DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_thoughts_is_favorite ON $tableName ($columnIsFavorite)
    ''');
  }

  /// Version upgrades handler
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // For future schema version migrations
  }
}
