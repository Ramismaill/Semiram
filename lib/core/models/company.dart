// lib/core/models/company.dart
//
// Dart data model for a Company entity.
//
// Maps to/from the `companies` table.
// Uses parseJsonArray helper (per DS recommendation) to safely
// decode JSON-encoded TEXT fields into List<String>.

import '../../shared/utils/json_helpers.dart';

class Company {
  final int id;
  final String officialName;
  final String commonName;
  final String? tickerSymbol;
  final int foundedYear;
  final int? foundedMonth;
  final String headquartersCity;
  final String headquartersCountry;
  final String? currentCeo;
  final int? employeeCount;
  final int? employeeCountYear;
  final int? revenueUsd;
  final int? revenueYear;
  final int? marketCapUsd;
  final String primaryFocus;
  final List<String> keyTechnologies;
  final List<String> notableCustomers;
  final String? careersUrl;
  final String? officialWebsite;
  final String shortDescription;
  final List<String> founderNames;
  final String? logoUrl;
  final String createdAt;
  final String updatedAt;

  const Company({
    required this.id,
    required this.officialName,
    required this.commonName,
    this.tickerSymbol,
    required this.foundedYear,
    this.foundedMonth,
    required this.headquartersCity,
    required this.headquartersCountry,
    this.currentCeo,
    this.employeeCount,
    this.employeeCountYear,
    this.revenueUsd,
    this.revenueYear,
    this.marketCapUsd,
    required this.primaryFocus,
    required this.keyTechnologies,
    required this.notableCustomers,
    this.careersUrl,
    this.officialWebsite,
    required this.shortDescription,
    required this.founderNames,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Constructs a Company from a database row (Map).
  /// Decodes JSON-encoded TEXT array fields safely.
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as int,
      officialName: map['official_name'] as String,
      commonName: map['common_name'] as String,
      tickerSymbol: map['ticker_symbol'] as String?,
      foundedYear: map['founded_year'] as int,
      foundedMonth: map['founded_month'] as int?,
      headquartersCity: map['headquarters_city'] as String,
      headquartersCountry: map['headquarters_country'] as String,
      currentCeo: map['current_ceo'] as String?,
      employeeCount: map['employee_count'] as int?,
      employeeCountYear: map['employee_count_year'] as int?,
      revenueUsd: map['revenue_usd'] as int?,
      revenueYear: map['revenue_year'] as int?,
      marketCapUsd: map['market_cap_usd'] as int?,
      primaryFocus: map['primary_focus'] as String,
      keyTechnologies: parseJsonArray(map['key_technologies'] as String?),
      notableCustomers: parseJsonArray(map['notable_customers'] as String?),
      careersUrl: map['careers_url'] as String?,
      officialWebsite: map['official_website'] as String?,
      shortDescription: map['short_description'] as String,
      founderNames: parseJsonArray(map['founder_names'] as String?),
      logoUrl: map['logo_url'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// Converts a Company back to a Map suitable for database insert/update.
  /// Encodes `List<String>` fields as JSON TEXT.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'official_name': officialName,
      'common_name': commonName,
      'ticker_symbol': tickerSymbol,
      'founded_year': foundedYear,
      'founded_month': foundedMonth,
      'headquarters_city': headquartersCity,
      'headquarters_country': headquartersCountry,
      'current_ceo': currentCeo,
      'employee_count': employeeCount,
      'employee_count_year': employeeCountYear,
      'revenue_usd': revenueUsd,
      'revenue_year': revenueYear,
      'market_cap_usd': marketCapUsd,
      'primary_focus': primaryFocus,
      'key_technologies': encodeJsonArray(keyTechnologies),
      'notable_customers': encodeJsonArray(notableCustomers),
      'careers_url': careersUrl,
      'official_website': officialWebsite,
      'short_description': shortDescription,
      'founder_names': encodeJsonArray(founderNames),
      'logo_url': logoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() => 'Company(id: $id, common_name: $commonName)';
}
