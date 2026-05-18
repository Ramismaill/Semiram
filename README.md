# Semiram

> The semiconductor world, decoded.

An offline-first mobile application that brings together the 20 leading semiconductor companies and the industry's historical timeline from 1947 to the present day.

**Course:** EFC304 — Mobile Application Development  
**University:** İstanbul Topkapı University, Computer Engineering  
**Student:** Ram Ismail (24040301052)  
**Instructor:** Prof. Dr. Buket İşler  
**Semester:** Spring 2026

---

## ✨ Features

- **20 semiconductor companies** with full profiles — CEO, revenue, market cap, key technologies, notable customers
- **19 historical industry events** (1947–2025), categorized and chronologically ordered
- **Relevance-ranked search** across 6 columns (exact match → prefix match → ecosystem matches)
- **Side-by-side comparison** of any two companies
- **Polymorphic bookmarks** with optimistic UI and rollback
- **Completely offline** — no internet connection required
- **Dark theme** with gold accent inspired by semiconductor fabrication aesthetics

---

## 🛠️ Tech Stack

- **Language:** Dart 3.11.4
- **Framework:** Flutter 3.41.6
- **Database:** SQLite via `sqflite` 2.3.0
- **Utilities:** `path`, `intl`, `path_provider`, `url_launcher`

No off-curriculum technologies were used. Pure Flutter widgets + raw SQL.

---

## 🏛️ Architecture

The project follows the **Repository Pattern** for strict separation of concerns:

```
lib/
├── core/
│   ├── database/       → DatabaseHelper, SeedLoader
│   ├── models/         → Company, IndustryEvent
│   └── repositories/   → Companies, Events, Bookmarks
├── features/
│   ├── home/           → HomeScreen
│   ├── companies/      → CompanyDetailScreen
│   ├── search/         → SearchScreen
│   ├── compare/        → CompareScreen
│   ├── bookmarks/      → BookmarksScreen
│   └── timeline/       → TimelineScreen
├── shared/             → Reusable widgets and utils
└── main.dart
```

- **SQL queries** live only in `repositories/`
- **Data models** live only in `models/`
- **UI logic** lives only in `features/`

---

## 🗄️ Database Schema

8 tables, 18 indexes:

| Table | Rows | Purpose |
|-------|------|---------|
| `companies` | 20 | Core semiconductor companies |
| `industry_events` | 19 | Timeline events |
| `bookmarks` | dynamic | Polymorphic bookmarks (CHECK-constrained) |
| `products`, `technology_nodes`, `company_node_history`, `careers_roles`, `company_careers` | schema-only | Reserved for future extensibility |

The `bookmarks` table uses a polymorphic design:

```sql
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL CHECK(entity_type IN ('company','event','role')),
  entity_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE (entity_type, entity_id)
);
```

A single table stores bookmarks for three different entity types, with database-level integrity via `CHECK` and `UNIQUE` constraints.

---

## 🔍 Search Implementation

The search query uses **6-column LIKE matching** with **relevance ranking**:

```sql
SELECT * FROM companies
WHERE common_name LIKE ? OR official_name LIKE ?
   OR primary_focus LIKE ? OR short_description LIKE ?
   OR key_technologies LIKE ? OR notable_customers LIKE ?
ORDER BY
  CASE
    WHEN common_name = ?    THEN 1   -- exact match first
    WHEN common_name LIKE ? THEN 2   -- prefix match second
    ELSE 3                           -- ecosystem matches last
  END,
  common_name COLLATE NOCASE ASC
```

Searching `"tsmc"` returns **TSMC first**, followed by ecosystem companies (ASML, Cadence, Synopsys, etc.) that mention TSMC.

---

## 🛡️ Error Handling

Four layers of error control:

1. `try`/`catch` with **optimistic UI rollback** on bookmark toggles
2. `FutureBuilder` error state with custom `ErrorView` widget
3. `ArgumentError` thrown when comparing a company to itself
4. SQL `CHECK` and `UNIQUE` constraints for database-level integrity

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.41.6+
- Dart 3.11.4+
- Android SDK or Xcode

### Run

```bash
git clone https://github.com/Ramismaill/Semiram.git
cd Semiram
flutter pub get
flutter run
```

---

## 📄 License

Academic project. Developed for EFC304 at İstanbul Topkapı University.

---

**Built with Flutter and SQLite — May 2026**