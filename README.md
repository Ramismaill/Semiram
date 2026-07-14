# Semiram

![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-sqflite-003B57?logo=sqlite)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20Web-brightgreen)

> The semiconductor world, decoded.

An **offline-first** Flutter application covering the 20 leading semiconductor companies and the industry's historical timeline — from the invention of the transistor (1947) to TSMC's 2nm production (2025). Runs on Android and in the browser from a single codebase.

**🌐 Live Demo:** [ramismaill.github.io/Semiram](https://ramismaill.github.io/Semiram)
**🎬 Video Walkthrough:** [YouTube](https://youtu.be/m2DDahdYed0)

---

## 📸 Screenshots

<p float="left">
  <img src="screenshots/home.png" width="200" alt="Home" />
  <img src="screenshots/detail.png" width="200" alt="Company Detail" />
  <img src="screenshots/search.png" width="200" alt="Search" />
  <img src="screenshots/timeline.png" width="200" alt="Timeline" />
</p>

---

## ✨ Features

- **20 semiconductor companies** with full profiles — CEO, revenue, market cap, key technologies, notable customers
- **Real company logos** via Clearbit, with letter-avatar fallback so offline mode still works
- **19 historical industry events** (1947–2025), categorized and chronologically ordered
- **Relevance-ranked search** across 6 columns (exact match → prefix match → ecosystem matches)
- **Side-by-side comparison** of any two companies
- **Polymorphic bookmarks** with optimistic UI and rollback
- **Full web support** — SQLite runs in the browser via WebAssembly with IndexedDB persistence
- **Completely offline** — no internet connection required for core features
- **Dark theme** with gold accent inspired by semiconductor fabrication aesthetics

---

## 🛠️ Tech Stack

- **Language:** Dart 3.11.4
- **Framework:** Flutter 3.41.6
- **Database:** SQLite via `sqflite` (mobile/desktop) and `sqflite_common_ffi_web` (browser, WASM + IndexedDB)
- **Utilities:** `path`, `intl`, `path_provider`, `url_launcher`

Pure Flutter widgets + raw SQL. The same SQL runs on every platform.

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
├── shared/             → Reusable widgets (CompanyLogo, …)
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

A single table stores bookmarks for three different entity types, with database-level integrity via `CHECK` and `UNIQUE` constraints. Schema migrations are versioned (`onUpgrade`), e.g. v2 added the `domain` column powering company logos.

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
- Android SDK, Xcode, or Chrome (for web)

### Run

```bash
git clone https://github.com/Ramismaill/Semiram.git
cd Semiram
flutter pub get
flutter run            # Android/iOS
flutter run -d chrome  # Web
```

### Build for web

```bash
flutter build web --release
# output in build/web
```

---

## 📄 License

Educational project, developed for EFC304 — Mobile Application Development at İstanbul Topkapı University (Software Engineering). All company data is publicly available and used for educational purposes. Semiram is not affiliated with or endorsed by any of the mentioned companies.

---

## 👤 Author

**Ram Ismail** — [GitHub](https://github.com/Ramismaill)

**Built with Flutter and SQLite — 2026**
