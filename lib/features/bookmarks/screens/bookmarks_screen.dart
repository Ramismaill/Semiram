// lib/features/bookmarks/screens/bookmarks_screen.dart
//
// Lists all companies the user has bookmarked.
//
// Data source: BookmarksRepository.getBookmarkedCompanies()
//   — runs an INNER JOIN between bookmarks and companies tables.
//
// Behavior:
//   - Loads on screen open
//   - Pull-to-refresh supported (RefreshIndicator)
//   - Auto-refreshes after returning from CompanyDetailScreen
//     (in case the user toggled a bookmark there)
//   - Empty state with helpful prompt when no bookmarks exist

import 'package:flutter/material.dart';

import '../../../core/models/company.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/repositories/bookmarks_repository.dart';
import '../../companies/screens/company_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late Future<List<Company>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Company>> _fetch() {
    return BookmarksRepository.instance.getBookmarkedCompanies();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetch();
    });
    await _future;
  }

  Future<void> _openDetail(Company company) async {
    // Push detail screen, then refresh on return —
    // the user may have toggled the bookmark while inside.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyDetailScreen(company: company),
      ),
    );
    if (!mounted) return;
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: FutureBuilder<List<Company>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString());
          }
          final companies = snapshot.data ?? const <Company>[];
          if (companies.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [_EmptyView()],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _BookmarkedList(
              companies: companies,
              onTap: _openDetail,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 56,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(fontSize: 17, color: context.textSubtle),
          ),
          const SizedBox(height: 8),
          Text(
            'Open any company and tap the bookmark icon to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.textFaint),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.cs.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to load bookmarks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textMedium),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// List
// ─────────────────────────────────────────────────────────

class _BookmarkedList extends StatelessWidget {
  const _BookmarkedList({required this.companies, required this.onTap});
  final List<Company> companies;
  final ValueChanged<Company> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CountBanner(count: companies.length),
        Expanded(
          child: ListView.separated(
            itemCount: companies.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _BookmarkTile(
                company: companies[index],
                onTap: () => onTap(companies[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CountBanner extends StatelessWidget {
  const _CountBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Text(
        '$count saved ${count == 1 ? "company" : "companies"}',
        style: TextStyle(
          fontSize: 13,
          color: context.textMedium,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({required this.company, required this.onTap});
  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(Icons.bookmark, color: theme.colorScheme.primary),
      title: Text(
        company.commonName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${company.headquartersCity}, ${company.headquartersCountry}',
          style: TextStyle(color: context.textSubtle, fontSize: 13),
        ),
      ),
      trailing: company.tickerSymbol == null
          ? Icon(Icons.chevron_right, color: context.textFaint)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    company.tickerSymbol!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: context.textFaint),
              ],
            ),
      onTap: onTap,
    );
  }
}
