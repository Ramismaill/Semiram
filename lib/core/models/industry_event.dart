// lib/core/models/industry_event.dart
//
// Dart model for the industry_events table.
//
// Maps cleanly to/from SQLite rows. The is_major INTEGER column is
// represented as a Dart bool for ergonomic UI code.

class IndustryEvent {
  const IndustryEvent({
    this.id,
    required this.eventTitle,
    this.eventDescription,
    required this.eventDate,
    this.eventCategory,
    required this.isMajor,
    this.relatedCompanyId,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String eventTitle;
  final String? eventDescription;
  final String eventDate; // ISO YYYY-MM-DD
  final String? eventCategory;
  final bool isMajor;
  final int? relatedCompanyId;
  final String createdAt;
  final String updatedAt;

  /// Extracts the year (YYYY) from event_date.
  int get year => int.parse(eventDate.substring(0, 4));

  /// Formats date as a human-readable string (e.g., "March 15, 2020").
  /// Falls back to event_date if parse fails.
  String formattedDate() {
    try {
      final date = DateTime.parse(eventDate);
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    } catch (_) {
      return eventDate;
    }
  }

  static String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }

  factory IndustryEvent.fromMap(Map<String, dynamic> map) {
    return IndustryEvent(
      id: map['id'] as int?,
      eventTitle: map['event_title'] as String,
      eventDescription: map['event_description'] as String?,
      eventDate: map['event_date'] as String,
      eventCategory: map['event_category'] as String?,
      isMajor: (map['is_major'] as int? ?? 0) == 1,
      relatedCompanyId: map['related_company_id'] as int?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'event_title': eventTitle,
      'event_description': eventDescription,
      'event_date': eventDate,
      'event_category': eventCategory,
      'is_major': isMajor ? 1 : 0,
      'related_company_id': relatedCompanyId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
