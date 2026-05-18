// lib/core/repositories/bookmarks_repository.dart
//
// Repository for the polymorphic `bookmarks` table.
//
// The table stores user-saved entries for any entity type:
//   - 'company' (id from companies table)
//   - 'event'   (id from industry_events table)  — future
//   - 'role'    (id from careers_roles table)    — future
//
// CHECK constraint at the schema level enforces valid entity_type.
// UNIQUE(entity_type, entity_id) prevents duplicate bookmarks.

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/company.dart';

class BookmarksRepository {
  BookmarksRepository._();
  static final BookmarksRepository instance = BookmarksRepository._();

  /// Canonical entity type strings (must match the CHECK constraint).
  static const String entityCompany = 'company';
  static const String entityEvent = 'event';
  static const String entityRole = 'role';

  /// Adds a bookmark.
  /// Idempotent — UNIQUE constraint blocks duplicates;
  /// `ConflictAlgorithm.ignore` makes a redundant call a no-op.
  Future<void> addBookmark(String entityType, int entityId) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert(
      'bookmarks',
      {
        'entity_type': entityType,
        'entity_id': entityId,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Removes a bookmark for the given (type, id) pair.
  /// No-op if the bookmark does not exist.
  Future<void> removeBookmark(String entityType, int entityId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'bookmarks',
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType, entityId],
    );
  }

  /// Returns true if the (type, id) pair is bookmarked.
  Future<bool> isBookmarked(String entityType, int entityId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'bookmarks',
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType, entityId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Returns all bookmarked companies, most recently saved first.
  ///
  /// Uses INNER JOIN to fetch full company data in a single SQL trip,
  /// rather than fetching bookmark rows then querying companies one by one.
  /// This is the classic relational pattern for resolving polymorphic refs
  /// to a specific entity type.
  Future<List<Company>> getBookmarkedCompanies() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery(
      '''
      SELECT c.* FROM companies c
      INNER JOIN bookmarks b
        ON b.entity_id = c.id AND b.entity_type = ?
      ORDER BY b.created_at DESC
      ''',
      [entityCompany],
    );
    return maps.map((row) => Company.fromMap(row)).toList();
  }

  /// Total count of all bookmarks (across entity types).
  Future<int> getTotalCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM bookmarks');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
