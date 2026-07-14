// lib/core/database/seed_loader.dart
//
// Loads seed data from JSON assets into the database.
//
// Currently seeds:
//   - 20 companies         (Batch 1)
//   - 15 industry events   (Batch 4 — self-seeded)
//
// Future batches (careers_roles, technology_nodes, products, etc.)
// can be added by following the same pattern: a private _loadX(db)
// method that reads the JSON, injects timestamps, and inserts rows.
//
// Per the Hybrid timestamp policy agreed in Phase 4, created_at and
// updated_at are injected at runtime rather than baked into JSON,
// so re-seeding always reflects the actual install time.

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class SeedLoader {
  SeedLoader._();

  /// Loads all available seed data into the given database.
  /// Called once during onCreate by DatabaseHelper.
  static Future<void> loadAll(Database db) async {
    await _loadCompanies(db);
    await _loadIndustryEvents(db);
    // Future: await _loadCareersRoles(db);
    // Future: await _loadTechnologyNodes(db);
    // Future: await _loadProducts(db);
    // Future: await _loadCompanyNodeHistory(db);
    // Future: await _loadCompanyCareers(db);
  }

  /// Re-runs the companies seed. Idempotent: existing rows are replaced
  /// by id (bookmarks stay valid because ids are stable), new rows are
  /// inserted. Used by migrations when the seed data grows.
  static Future<void> reseedCompanies(Database db) => _loadCompanies(db);

  static Future<void> _loadCompanies(Database db) async {
    final raw =
        await rootBundle.loadString('assets/data/seed/companies.json');
    final list = json.decode(raw) as List<dynamic>;
    final now = DateTime.now().toUtc().toIso8601String();

    for (final item in list) {
      final map = Map<String, dynamic>.from(item as Map);
      map['created_at'] = now;
      map['updated_at'] = now;
      await db.insert(
        'companies',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<void> _loadIndustryEvents(Database db) async {
    final raw =
        await rootBundle.loadString('assets/data/seed/industry_events.json');
    final list = json.decode(raw) as List<dynamic>;
    final now = DateTime.now().toUtc().toIso8601String();

    for (final item in list) {
      final map = Map<String, dynamic>.from(item as Map);
      map['created_at'] = now;
      map['updated_at'] = now;
      await db.insert('industry_events', map);
    }
  }
}
