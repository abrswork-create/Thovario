import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';

/// Database provider for Thovario.
class AppDatabase {
  static const String _defaultDbName = 'thovario.db';

  final Database? _overrideDb;
  final String _dbName;
  Database? _db;

  AppDatabase({Database? database, this._dbName = _defaultDbName})
    : _overrideDb = database;

  /// Returns the singleton-like instance of the active database.
  Future<Database> get database async {
    if (_overrideDb != null) {
      return _overrideDb;
    }
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: DatabaseMigrations.currentVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
