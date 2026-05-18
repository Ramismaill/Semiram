// lib/core/repositories/companies_repository.dart
//
// Repository layer for Company entities.
//
// Encapsulates all SQL queries on the `companies` table
// so that UI code never speaks directly to the database.

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/company.dart';

class CompaniesRepository {
  CompaniesRepository._();
  static final CompaniesRepository instance = CompaniesRepository._();

  /// Returns all companies. Default order: alphabetical by common name.
  Future<List<Company>> getAllCompanies({
    String orderBy = 'common_name ASC',
  }) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('companies', orderBy: orderBy);
    return maps.map((row) => Company.fromMap(row)).toList();
  }

  /// Returns a single company by id, or null if not found.
  Future<Company?> getCompanyById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Company.fromMap(maps.first);
  }

  /// Returns the total number of companies (for stats / debug).
  Future<int> getCompaniesCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM companies');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Searches companies across 6 text columns using SQL LIKE.
  /// Case-insensitive (COLLATE NOCASE), backed by composite index
  /// `idx_companies_search` for performance.
  ///
  /// Results are relevance-ranked:
  ///   1. Exact match on common_name (e.g. "tsmc" → TSMC first)
  ///   2. Prefix match on common_name (e.g. "nv" → NVIDIA before others)
  ///   3. All other matches (description, customers, technologies, etc.)
  /// Within each rank, results are alphabetical.
  Future<List<Company>> searchCompanies(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <Company>[];

    final db = await DatabaseHelper.instance.database;
    final pattern = '%$trimmed%';
    final prefix = '$trimmed%';

    final maps = await db.rawQuery(
      '''
      SELECT * FROM companies
      WHERE common_name        LIKE ? COLLATE NOCASE
         OR official_name      LIKE ? COLLATE NOCASE
         OR primary_focus      LIKE ? COLLATE NOCASE
         OR short_description  LIKE ? COLLATE NOCASE
         OR key_technologies   LIKE ? COLLATE NOCASE
         OR notable_customers  LIKE ? COLLATE NOCASE
      ORDER BY
        CASE
          WHEN common_name = ?    COLLATE NOCASE THEN 1
          WHEN common_name LIKE ? COLLATE NOCASE THEN 2
          ELSE 3
        END,
        common_name COLLATE NOCASE ASC
      ''',
      [pattern, pattern, pattern, pattern, pattern, pattern, trimmed, prefix],
    );

    return maps.map((row) => Company.fromMap(row)).toList();
  }

  /// Compares two companies side-by-side using a single SQL query.
  ///
  /// Uses UNION ALL to combine two single-row SELECTs into one result set,
  /// preserving order: index 0 = Company A, index 1 = Company B.
  ///
  /// UNION ALL is preferred over UNION because:
  ///   1. It preserves order (UNION may sort/deduplicate)
  ///   2. It is faster (no duplicate-elimination pass)
  ///   3. Two known PKs cannot collide, so deduplication is unnecessary
  ///
  /// Throws ArgumentError if both ids are equal.
  /// Returns fewer than 2 elements if either id is not found.
  Future<List<Company>> compareTwoCompanies(int idA, int idB) async {
    if (idA == idB) {
      throw ArgumentError('Cannot compare a company to itself');
    }
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery(
      '''
      SELECT * FROM companies WHERE id = ?
      UNION ALL
      SELECT * FROM companies WHERE id = ?
      ''',
      [idA, idB],
    );
    return maps.map((row) => Company.fromMap(row)).toList();
  }

  /// Returns companies filtered by country.
  Future<List<Company>> getCompaniesByCountry(String country) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'companies',
      where: 'headquarters_country = ?',
      whereArgs: [country],
      orderBy: 'common_name ASC',
    );
    return maps.map((row) => Company.fromMap(row)).toList();
  }

  /// Top N companies by revenue (descending).
  Future<List<Company>> getTopByRevenue({int limit = 5}) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'companies',
      where: 'revenue_usd IS NOT NULL',
      orderBy: 'revenue_usd DESC',
      limit: limit,
    );
    return maps.map((row) => Company.fromMap(row)).toList();
  }
}
