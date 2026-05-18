// lib/features/search/screens/search_screen.dart
//
// Real-time search across all companies.
//
// Behavior:
//   - User types → onChanged fires → searchCompanies() runs
//   - Results render instantly (no debounce — 20 rows query is < 5ms)
//   - Tap result → opens CompanyDetailScreen (reuse from Phase 6)
//   - Empty query → "Type to search" prompt
//   - No matches → "No results for 'X'"
//
// SQL strategy: LIKE across 6 text columns with COLLATE NOCASE,
// hitting the idx_companies_search composite index.

import 'package:flutter/material.dart';

import '../../../core/models/company.dart';
import '../../../core/repositories/companies_repository.dart';
import '../../companies/screens/company_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Company> _results = const <Company>[];
  bool _hasSearched = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Called every time the search text changes.
  /// Empty query resets the UI to the prompt state.
  Future<void> _onChanged(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _results = const <Company>[];
        _hasSearched = false;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results =
          await CompaniesRepository.instance.searchCompanies(trimmed);
      if (!mounted) return;
      setState(() {
        _results = results;
        _hasSearched = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = const <Company>[];
        _hasSearched = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void _clearSearch() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 17, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search companies, technologies, customers…',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.white60,
                    onPressed: _clearSearch,
                    tooltip: 'Clear',
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasSearched) {
      return _PromptView();
    }
    if (_results.isEmpty) {
      return _NoResultsView(query: _controller.text);
    }
    return _ResultsList(results: _results, query: _controller.text);
  }
}

// ─────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────

class _PromptView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 56,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Type to search',
              style: TextStyle(fontSize: 17, color: Colors.white60),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find companies by name, technology, or customer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 56, color: Colors.white30),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              style: const TextStyle(fontSize: 17, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different keyword',
              style: TextStyle(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Results
// ─────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results, required this.query});
  final List<Company> results;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResultsHeader(count: results.length),
        Expanded(
          child: ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _SearchResultTile(company: results[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count});
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
        '$count ${count == 1 ? "result" : "results"}',
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white70,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        company.commonName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${company.headquartersCity}, ${company.headquartersCountry}',
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ),
      trailing: company.tickerSymbol == null
          ? const Icon(Icons.chevron_right, color: Colors.white38)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    company.tickerSymbol!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white38),
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
