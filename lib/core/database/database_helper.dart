// lib/core/database/database_helper.dart
//
// Singleton database manager for Semiram.
//
// Responsibilities:
//   - Open the SQLite database on first access
//   - Run schema creation on first launch (via onCreate)
//   - Trigger seed data loading after schema creation
//   - Provide a single Database instance to repositories
//
// Usage:
//   final db = await DatabaseHelper.instance.database;
//   final results = await db.query('companies');

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'schema.dart';
import 'seed_loader.dart';

class DatabaseHelper {
  // Private constructor — enforces singleton pattern.
  DatabaseHelper._privateConstructor();

  // The single shared instance, used everywhere as DatabaseHelper.instance.
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Cached database handle. Initialized on first access.
  static Database? _database;

  /// Returns the database, opening (and creating) it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Opens the database file, runs onCreate if it doesn't exist.
  Future<Database> _initDatabase() async {
    // Get platform-appropriate documents directory.
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, DatabaseSchema.databaseName);

    return await openDatabase(
      dbPath,
      version: DatabaseSchema.version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Enables foreign key support.
  /// SQLite has FKs disabled by default; we must opt in per connection.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Runs only on first database creation.
  /// Creates all tables, FTS5 virtual tables, triggers, and indexes,
  /// then loads seed data from assets.
  Future<void> _onCreate(Database db, int version) async {
    // Run all schema statements in a single transaction for atomicity.
    await db.transaction((txn) async {
      for (final statement in DatabaseSchema.allCreateStatements) {
        await txn.execute(statement);
      }
    });

    // Load seed data from assets/data/seed/*.json
    await SeedLoader.loadAll(db);
  }

  /// Called when the schema version increases.
  /// For now, we do a destructive upgrade (drop and recreate).
  /// Production apps should use proper migrations.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For MVP: simple destructive upgrade. Replace with proper migrations later.
    // ignore: avoid_print
    print('Upgrading database from v$oldVersion to v$newVersion');

    // Drop all tables and recreate (destructive — only suitable for development).
    final tables = [
      'companies_fts',
      'events_fts',
      'careers_fts',
      'bookmarks',
      'company_careers',
      'company_node_history',
      'products',
      'careers_roles',
      'industry_events',
      'technology_nodes',
      'companies',
    ];
    for (final table in tables) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }
    await _onCreate(db, newVersion);
  }

  /// Closes the database. Useful for testing or app shutdown.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Deletes the database file. Useful for testing or "reset app data" feature.
  Future<void> deleteDatabaseFile() async {
    await close();
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, DatabaseSchema.databaseName);
    await deleteDatabase(dbPath);
  }
}
