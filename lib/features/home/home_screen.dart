// lib/features/home/home_screen.dart
//
// Home screen for Semiram.
//
// AppBar actions (left to right):
//   - Compare    → CompareScreen   (Phase 8)
//   - Timeline   → TimelineScreen  (Phase 9)
//   - Bookmarks  → BookmarksScreen (Phase 10)
//   - Search     → SearchScreen    (Phase 7)
//
// Body: scrollable list of all 20 companies; tap to open detail.
// The hero banner uses a gradient with a large champagne-gold count.

import 'package:flutter/material.dart';

import '../../core/models/company.dart';
import '../../core/repositories/companies_repository.dart';
import '../bookmarks/screens/bookmarks_screen.dart';
import '../companies/screens/company_detail_screen.dart';
import '../compare/screens/compare_screen.dart';
import '../search/screens/search_screen.dart';
import '../timeline/screens/timeline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<Company>> _companiesFuture;

  @override
  void initState() {
    super.initState();
    _companiesFuture = CompaniesRepository.instance.getAllCompanies();
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _openCompare() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompareScreen()),
    );
  }

  void _openBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookmarksScreen()),
    );
  }

  void _openTimeline() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TimelineScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Semiram',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: _openCompare,
            tooltip: 'Compare',
          ),
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: _openTimeline,
            tooltip: 'Timeline',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: _openBookmarks,
            tooltip: 'Bookmarks',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
            tooltip: 'Search',
          ),
        ],
      ),
      body: FutureBuilder<List<Company>>(
        future: _companiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }
          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString());
          }
          final companies = snapshot.data ?? const <Company>[];
          if (companies.isEmpty) {
            return const _EmptyView();
          }
          return _CompanyListView(companies: companies);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          const Text(
            'Initializing semiconductor database…',
            style: TextStyle(color: Color(0xFF9BA4B5), letterSpacing: 0.3),
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
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFCF6679)),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9BA4B5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No companies in the database.',
        style: TextStyle(color: Color(0xFF9BA4B5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Main content
// ─────────────────────────────────────────────────────────

class _CompanyListView extends StatelessWidget {
  const _CompanyListView({required this.companies});
  final List<Company> companies;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroBanner(count: companies.length),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 4),
            itemCount: companies.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              return _CompanyTile(company: companies[index]);
            },
          ),
        ),
      ],
    );
  }
}

// Hero banner — gradient background, large champagne-gold count,
// premium typography hierarchy.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.surfaceContainerHigh,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tagline
          Row(
            children: [
              Container(
                width: 24,
                height: 1.5,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'THE SEMICONDUCTOR WORLD, DECODED',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Large count
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'companies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'indexed across the global supply chain',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyTile extends StatelessWidget {
  const _CompanyTile({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Text(
        company.commonName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${company.headquartersCity}, ${company.headquartersCountry}',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            fontSize: 13,
            letterSpacing: 0.1,
          ),
        ),
      ),
      trailing: company.tickerSymbol == null
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    company.tickerSymbol!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyDetailScreen(company: company),
          ),
        );
      },
    );
  }
}
