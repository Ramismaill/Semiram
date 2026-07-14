- **SQL queries** live only in `repositories/`
- **Data models** live only in `models/`
- **UI logic** lives only in `features/`

---

## 🗄️ Database Schema

**8 tables, 18 indexes:**

| Table | Purpose |
|-------|---------|
| `companies` | 30 semiconductor companies (v3 schema with `domain`) |
| `industry_events` | 19 historical milestones |
| `bookmarks` | Polymorphic bookmarks (CHECK-constrained) |
| `products` | Products per company (1:N) |
| `technology_nodes` | Process nodes timeline |
| `company_node_history` | M2M: companies ↔ nodes |
| `careers_roles` | Engineering roles |
| `company_careers` | M2M: companies ↔ roles |

**Polymorphic Bookmarks Design:**
```sql
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL CHECK(entity_type IN ('company','event','role')),
  entity_id INTEGER NOT NULL,
  note TEXT,
  created_at TEXT NOT NULL,
  UNIQUE (entity_type, entity_id)
);
```

**Schema Versioning:**
- `v1`: Initial schema (20 companies)
- `v2`: Added `domain` column for logos
- `v3`: Added 10 new companies (NXP, Infineon, ST, AMAT, Lam, KLA, TEL, Renesas, onsemi, UMC)

---

## 🔍 Search Implementation

Relevance‑ranked search across 6 columns with `LIKE` matching:

```sql
SELECT * FROM companies
WHERE common_name LIKE ? OR official_name LIKE ?
   OR primary_focus LIKE ? OR short_description LIKE ?
   OR key_technologies LIKE ? OR notable_customers LIKE ?
ORDER BY
  CASE
    WHEN common_name = ?    THEN 1   -- exact match
    WHEN common_name LIKE ? THEN 2   -- prefix match
    ELSE 3                           -- ecosystem matches
  END,
  common_name COLLATE NOCASE ASC
```

**Example:** Searching "tsmc" returns TSMC first, followed by ecosystem companies (ASML, Cadence, Synopsys) that mention TSMC.

---

## 🛡️ Error Handling

Four layers of error control:

1. **`try/catch`** – optimistic UI rollback on bookmark toggles
2. **`FutureBuilder`** – error state with custom `ErrorView` widget
3. **`ArgumentError`** – prevents comparing a company to itself
4. **SQL `CHECK` & `UNIQUE`** – database‑level integrity

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.41.6+
- Dart 3.11.4+
- Android SDK, Xcode, or Chrome (for web)

### Run Locally

```bash
git clone https://github.com/Ramismaill/Semiram.git
cd Semiram
flutter pub get
flutter run            # Android/iOS
flutter run -d chrome  # Web
```

### Build for Web

```bash
flutter build web --release --base-href /Semiram/
# output in build/web
```

### Download Logos (Optional)

```bash
powershell -ExecutionPolicy Bypass -File tools\download_logos.ps1 -Token YOUR_LOGO_DEV_KEY
```

---

## 📄 License

Educational project developed for **EFC304 – Mobile Application Development** at **İstanbul Topkapı University** (Software Engineering).
All company data is publicly available and used for educational purposes.
**Semiram is not affiliated with or endorsed by any of the mentioned companies.**

---

## 👤 Author

**Ram Ismail** – [GitHub](https://github.com/Ramismaill) | [LinkedIn](https://www.linkedin.com/in/ram-ismail-060333266/)

Built with ❤️ and Flutter – 2026