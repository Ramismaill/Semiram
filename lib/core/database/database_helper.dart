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
// Platform support:
//   - Android/iOS/desktop: sqflite (native SQLite via file system)
//   - Web: sqflite_common_ffi_web (SQLite compiled to WebAssembly,
//     persisted in the browser via IndexedDB)
//
// Usage:
//   final db = await DatabaseHelper.instance.database;
//   final results = await db.query('companies');

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
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

  /// Opens the database, runs onCreate if it doesn't exist.
  ///
  /// On web there is no file system: we use the WASM-backed factory and
  /// a simple database name (persisted in IndexedDB). On mobile/desktop
  /// we resolve a real file path via path_provider.
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      final factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        DatabaseSchema.databaseName,
        options: OpenDatabaseOptions(
          version: DatabaseSchema.version,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }

    // Mobile/desktop: get platform-appropriate documents directory.
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
  /// Creates all tables and indexes, then loads seed data from assets.
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
  /// ✅ تم التعديل: أصبحت ترقية غير مدمرة (Non-destructive migration).
  /// بدلاً من حذف الجداول، نضيف الأعمدة الجديدة فقط.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // تجاهل التحذير المطبوع
    // ignore: avoid_print
    print('Upgrading database from v$oldVersion to v$newVersion');

    // 📌 الترقية من الإصدار 1 إلى 2: إضافة عمود 'domain' في جدول companies
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE companies ADD COLUMN domain TEXT');
        // ignore: avoid_print
        print('✅ Migration: Added domain column to companies table.');
      } catch (e) {
        // لو العمود موجود مسبقاً (مثلاً في حالة إعادة التشغيل)، نتجاهل الخطأ
        // ignore: avoid_print
        print('⚠️ Migration: Column domain might already exist. $e');
      }
    }

    // هنا هنضيف ترقيات مستقبلية لو احتجناها، مثلاً:
    // if (oldVersion < 3) { await db.execute('...'); }
  }

  /// Closes the database. Useful for testing or app shutdown.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Deletes the database. Useful for testing or "reset app data" feature.
  Future<void> deleteDatabaseFile() async {
    await close();
    if (kIsWeb) {
      await databaseFactoryFfiWeb.deleteDatabase(DatabaseSchema.databaseName);
      return;
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, DatabaseSchema.databaseName);
    await deleteDatabase(dbPath);
  }
}