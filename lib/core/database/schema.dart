// lib/core/database/schema.dart
//
// Database schema definitions for Semiram.
//
// Tables (8):
//   1. companies              - main entity
//   2. products               - products per company (1:N)
//   3. technology_nodes       - process nodes timeline
//   4. company_node_history   - M2M: companies <-> nodes
//   5. industry_events        - timeline events
//   6. careers_roles          - engineering roles
//   7. company_careers        - M2M: companies <-> roles
//   8. bookmarks              - user-saved items (polymorphic)
//
// Indexes: 18 total (15 standard + 3 search composite indexes)
// Search strategy: LIKE-based queries with composite indexes
//                  (no FTS5 — using only standard SQLite features)

class DatabaseSchema {
  /// Database schema version. Increment when schema changes.
  /// v2: added domain column. v3: expanded seed to 30 companies.
  /// v4: refreshed company data to July 2026 values.
  static const int version = 4;

  /// Database filename.
  static const String databaseName = 'semiram.db';

  // ──────────────────────────────────────────────────────────────
  // TABLE: companies
  // ──────────────────────────────────────────────────────────────
  static const String createCompaniesTable = '''
    CREATE TABLE companies (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      official_name TEXT NOT NULL,
      common_name TEXT NOT NULL,
      ticker_symbol TEXT,
      founded_year INTEGER NOT NULL,
      founded_month INTEGER,
      headquarters_city TEXT NOT NULL,
      headquarters_country TEXT NOT NULL,
      current_ceo TEXT,
      employee_count INTEGER,
      employee_count_year INTEGER,
      revenue_usd INTEGER,
      revenue_year INTEGER,
      market_cap_usd INTEGER,
      primary_focus TEXT NOT NULL,
      key_technologies TEXT,
      notable_customers TEXT,
      careers_url TEXT,
      official_website TEXT,
      short_description TEXT NOT NULL,
      founder_names TEXT,
      logo_url TEXT,
      domain TEXT,              -- ✅ العمود الجديد (لشعارات Clearbit)
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // TABLE: technology_nodes
  // ──────────────────────────────────────────────────────────────
  static const String createTechnologyNodesTable = '''
    CREATE TABLE technology_nodes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      node_name TEXT NOT NULL UNIQUE,
      size_nm REAL,
      introduction_year INTEGER NOT NULL,
      is_volume_production INTEGER DEFAULT 0,
      description TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // TABLE: products (depends on companies, technology_nodes)
  // ──────────────────────────────────────────────────────────────
  static const String createProductsTable = '''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      company_id INTEGER NOT NULL,
      product_name TEXT NOT NULL,
      category TEXT,
      description TEXT,
      release_year INTEGER,
      node_id INTEGER,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
      FOREIGN KEY (node_id) REFERENCES technology_nodes(id) ON DELETE SET NULL
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // TABLE: company_node_history (M2M)
  // ──────────────────────────────────────────────────────────────
  static const String createCompanyNodeHistoryTable = '''
    CREATE TABLE company_node_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      company_id INTEGER NOT NULL,
      node_id INTEGER NOT NULL,
      adoption_year INTEGER NOT NULL,
      product_example TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
      FOREIGN KEY (node_id) REFERENCES technology_nodes(id) ON DELETE CASCADE
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // TABLE: industry_events
  // ──────────────────────────────────────────────────────────────
  static const String createIndustryEventsTable = '''
    CREATE TABLE industry_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      event_title TEXT NOT NULL,
      event_description TEXT,
      event_date TEXT NOT NULL,
      event_category TEXT,
      is_major INTEGER DEFAULT 0,
      related_company_id INTEGER,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (related_company_id) REFERENCES companies(id) ON DELETE SET NULL
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // TABLE: careers_roles
  // ──────────────────────────────────────────────────────────────
  static const String createCareersRolesTable = '''
    CREATE TABLE careers_roles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      role_title TEXT NOT NULL UNIQUE,
      category TEXT NOT NULL,
      description TEXT,
      required_skills TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // TABLE: company_careers (M2M)
  // ──────────────────────────────────────────────────────────────
  static const String createCompanyCareersTable = '''
    CREATE TABLE company_careers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      company_id INTEGER NOT NULL,
      role_id INTEGER NOT NULL,
      careers_url_specific TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
      FOREIGN KEY (role_id) REFERENCES careers_roles(id) ON DELETE CASCADE,
      UNIQUE (company_id, role_id)
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // TABLE: bookmarks (polymorphic)
  // ──────────────────────────────────────────────────────────────
  static const String createBookmarksTable = '''
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entity_type TEXT NOT NULL CHECK(entity_type IN ('company', 'event', 'role')),
      entity_id INTEGER NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL,
      UNIQUE (entity_type, entity_id)
    )
  ''';

  // ──────────────────────────────────────────────────────────────
  // INDEXES (18 total)
  //   - 15 standard B-tree indexes on filter/lookup columns
  //   - 3 composite indexes covering search columns (LIKE queries)
  // ──────────────────────────────────────────────────────────────
  static const List<String> createIndexes = [
    // companies — common filters
    'CREATE INDEX idx_companies_country ON companies(headquarters_country)',
    'CREATE INDEX idx_companies_founded_year ON companies(founded_year)',
    'CREATE INDEX idx_companies_revenue ON companies(revenue_usd)',

    // products — by company and year
    'CREATE INDEX idx_products_company ON products(company_id)',
    'CREATE INDEX idx_products_release_year ON products(release_year)',

    // technology_nodes — by year
    'CREATE INDEX idx_nodes_introduction_year ON technology_nodes(introduction_year)',

    // company_node_history — M2M lookups
    'CREATE INDEX idx_node_history_company ON company_node_history(company_id)',
    'CREATE INDEX idx_node_history_node ON company_node_history(node_id)',
    'CREATE INDEX idx_node_history_year ON company_node_history(adoption_year)',

    // industry_events — by date and category
    'CREATE INDEX idx_events_date ON industry_events(event_date)',
    'CREATE INDEX idx_events_category ON industry_events(event_category)',

    // careers_roles — by category
    'CREATE INDEX idx_careers_category ON careers_roles(category)',

    // company_careers — M2M lookups
    'CREATE INDEX idx_company_careers_company ON company_careers(company_id)',
    'CREATE INDEX idx_company_careers_role ON company_careers(role_id)',

    // bookmarks — polymorphic lookup
    'CREATE INDEX idx_bookmarks_entity ON bookmarks(entity_type, entity_id)',

    // ─── Search-supporting composite indexes (LIKE queries) ───
    'CREATE INDEX idx_companies_search ON companies(common_name, official_name, primary_focus, short_description)',
    'CREATE INDEX idx_events_search ON industry_events(event_title, event_description, event_category)',
    'CREATE INDEX idx_careers_search ON careers_roles(role_title, category, description, required_skills)',
  ];

  // ──────────────────────────────────────────────────────────────
  // ALL CREATE STATEMENTS (in dependency order)
  // ──────────────────────────────────────────────────────────────
  static const List<String> allCreateStatements = [
    // 1. Tables (independent first, then dependent)
    createCompaniesTable,
    createTechnologyNodesTable,
    createProductsTable,
    createCompanyNodeHistoryTable,
    createIndustryEventsTable,
    createCareersRolesTable,
    createCompanyCareersTable,
    createBookmarksTable,

    // 2. Indexes (after tables)
    ...createIndexes,
  ];
}