// lib/core/repositories/events_repository.dart
//
// Repository layer for the industry_events table.

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/industry_event.dart';

class EventsRepository {
  EventsRepository._();
  static final EventsRepository instance = EventsRepository._();

  /// Returns all events, ordered chronologically.
  /// Uses idx_events_date for performance.
  Future<List<IndustryEvent>> getAllEvents({bool ascending = true}) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'industry_events',
      orderBy: 'event_date ${ascending ? "ASC" : "DESC"}',
    );
    return maps.map(IndustryEvent.fromMap).toList();
  }

  /// Returns total count of events.
  Future<int> getEventsCount() async {
    final db = await DatabaseHelper.instance.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) AS count FROM industry_events');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Returns only major events (is_major = 1).
  Future<List<IndustryEvent>> getMajorEvents() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'industry_events',
      where: 'is_major = 1',
      orderBy: 'event_date ASC',
    );
    return maps.map(IndustryEvent.fromMap).toList();
  }

  /// Returns events filtered by category.
  /// Uses idx_events_category for performance.
  Future<List<IndustryEvent>> getEventsByCategory(String category) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'industry_events',
      where: 'event_category = ?',
      whereArgs: [category],
      orderBy: 'event_date ASC',
    );
    return maps.map(IndustryEvent.fromMap).toList();
  }
}
