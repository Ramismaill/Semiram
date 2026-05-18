// lib/shared/utils/json_helpers.dart
//
// Helper utilities for working with JSON data stored as TEXT in SQLite.
// Per DS architecture: arrays are stored as JSON-encoded TEXT
// (e.g., key_technologies, notable_customers, founder_names, required_skills).

import 'dart:convert';

/// Parses a JSON-encoded array string into a `List<String>`.
///
/// Handles edge cases gracefully:
/// - null input → empty list
/// - empty string → empty list
/// - malformed JSON → empty list (with debug log)
/// - non-array JSON → empty list
///
/// Used consistently across all model fromMap() implementations
/// to ensure data integrity throughout the app.
List<String> parseJsonArray(String? jsonString) {
  if (jsonString == null || jsonString.isEmpty) return [];
  try {
    final decoded = json.decode(jsonString);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
    return [];
  } catch (e) {
    // Defensive: malformed JSON should not crash the app
    return [];
  }
}

/// Encodes a `List<String>` back to JSON-encoded TEXT for storage.
/// Inverse of parseJsonArray.
String encodeJsonArray(List<String> list) {
  return json.encode(list);
}
