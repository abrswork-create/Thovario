import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/migrations.dart';
import '../models/thought.dart';

/// Database service performing parameterized CRUD operations on [Thought] records.
class DatabaseService {
  final AppDatabase _appDatabase;

  DatabaseService({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase();

  Future<Database> get _db async => await _appDatabase.database;

  /// Inserts a new thought record.
  Future<int> insert(Thought thought) async {
    final db = await _db;
    return await db.insert(
      DatabaseMigrations.tableName,
      thought.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all thoughts sorted by creation date.
  Future<List<Thought>> getAll({bool newestFirst = true}) async {
    final db = await _db;
    final order = newestFirst ? 'DESC' : 'ASC';
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseMigrations.tableName,
      orderBy: '${DatabaseMigrations.columnCreatedAt} $order',
    );
    return maps.map((map) => Thought.fromMap(map)).toList();
  }

  /// Retrieves a single thought by ID, or null if not found.
  Future<Thought?> getById(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseMigrations.tableName,
      where: '${DatabaseMigrations.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Thought.fromMap(maps.first);
  }

  /// Updates an existing thought.
  Future<int> update(Thought thought) async {
    final db = await _db;
    return await db.update(
      DatabaseMigrations.tableName,
      thought.toMap(),
      where: '${DatabaseMigrations.columnId} = ?',
      whereArgs: [thought.id],
    );
  }

  /// Deletes a single thought by ID.
  Future<int> delete(String id) async {
    final db = await _db;
    return await db.delete(
      DatabaseMigrations.tableName,
      where: '${DatabaseMigrations.columnId} = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all thought records.
  Future<int> deleteAll() async {
    final db = await _db;
    return await db.delete(DatabaseMigrations.tableName);
  }

  /// Searches thoughts by title or content matching the given query string.
  Future<List<Thought>> search(String query, {bool newestFirst = true}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return getAll(newestFirst: newestFirst);
    }

    final db = await _db;
    final order = newestFirst ? 'DESC' : 'ASC';
    final pattern = '%$trimmed%';

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseMigrations.tableName,
      where:
          '${DatabaseMigrations.columnTitle} LIKE ? OR ${DatabaseMigrations.columnContent} LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: '${DatabaseMigrations.columnCreatedAt} $order',
    );

    return maps.map((map) => Thought.fromMap(map)).toList();
  }

  /// Retrieves only favorited thoughts.
  Future<List<Thought>> getFavorites({bool newestFirst = true}) async {
    final db = await _db;
    final order = newestFirst ? 'DESC' : 'ASC';
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseMigrations.tableName,
      where: '${DatabaseMigrations.columnIsFavorite} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseMigrations.columnCreatedAt} $order',
    );
    return maps.map((map) => Thought.fromMap(map)).toList();
  }

  /// Retrieves thoughts filtered by a specific mood.
  Future<List<Thought>> getByMood(String mood, {bool newestFirst = true}) async {
    final db = await _db;
    final order = newestFirst ? 'DESC' : 'ASC';
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseMigrations.tableName,
      where: '${DatabaseMigrations.columnMood} = ?',
      whereArgs: [mood],
      orderBy: '${DatabaseMigrations.columnCreatedAt} $order',
    );
    return maps.map((map) => Thought.fromMap(map)).toList();
  }

  /// Calculates distribution counts for each mood.
  Future<Map<String, int>> getMoodCounts() async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT ${DatabaseMigrations.columnMood}, COUNT(*) as count
      FROM ${DatabaseMigrations.tableName}
      GROUP BY ${DatabaseMigrations.columnMood}
    ''');
    final Map<String, int> counts = {};
    for (final row in result) {
      final mood = row[DatabaseMigrations.columnMood] as String? ?? 'reflective';
      final count = (row['count'] as num?)?.toInt() ?? 0;
      counts[mood] = count;
    }
    return counts;
  }

  /// Updates the favorite status of a thought.
  Future<int> setFavorite(String id, bool isFavorite) async {
    final db = await _db;
    return await db.update(
      DatabaseMigrations.tableName,
      {DatabaseMigrations.columnIsFavorite: isFavorite ? 1 : 0},
      where: '${DatabaseMigrations.columnId} = ?',
      whereArgs: [id],
    );
  }
}
