// lib/features/companies/screens/company_detail_screen.dart
//
// Full profile screen for a single company.
//
// Receives a Company object via constructor (no DB call needed —
// data is already loaded by HomeScreen).
//
// AppBar action: bookmark toggle (Phase 10).
// Tapping the bookmark icon adds/removes the company from saved bookmarks.
//
// Layout sections (each renders only when its data exists):
//   1. Header     — logo + common name + ticker + location
//   2. Stats      — CEO, founded, employees, revenue, market cap
//   3. About      — primary focus + short description
//   4. Tech       — chip cloud of key technologies
//   5. Customers  — chip cloud of notable customers
//   6. Founders   — list of founders
//   7. Actions    — careers + website buttons

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/company.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/repositories/bookmarks_repository.dart';
import '../../../shared/widgets/company_logo.dart'; // ✅ استيراد الشعار

class CompanyDetailScreen extends StatelessWidget {
  const CompanyDetailScreen({super.key, required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company.commonName),
        actions: [
          _BookmarkToggle(companyId: company.id),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderBlock(company: company),
            _StatsBlock(company: company),
            _AboutBlock(company: company),
            _ChipsBlock(
              title: 'Key Technologies',
              items: company.keyTechnologies,
            ),
            _ChipsBlock(
              title: 'Notable Customers',
              items: company.notableCustomers,
            ),
            _FoundersBlock(founders: company.founderNames),
            _ActionsBlock(company: company),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Bookmark toggle (Phase 10)
// ─────────────────────────────────────────────────────────

class _BookmarkToggle extends StatefulWidget {
  const _BookmarkToggle({required this.companyId});
  final int companyId;

  @override
  State<_BookmarkToggle> createState() => _BookmarkToggleState();
}

class _BookmarkToggleState extends State<_BookmarkToggle> {
  bool? _isBookmarked; // null = loading

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final saved = await BookmarksRepository.instance.isBookmarked(
      BookmarksRepository.entityCompany,
      widget.companyId,
    );
    if (!mounted) return;
    setState(() => _isBookmarked = saved);
  }

  Future<void> _toggle() async {
    final current = _isBookmarked;
    if (current == null) return; // still loading

    // Optimistic UI update — flip immediately, persist after.
    setState(() => _isBookmarked = !current);
    try {
      if (current) {
        await BookmarksRepository.instance.removeBookmark(
          BookmarksRepository.entityCompany,
          widget.companyId,
        );
      } else {
        await BookmarksRepository.instance.addBookmark(
          BookmarksRepository.entityCompany,
          widget.companyId,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(current ? 'Removed from bookmarks' : 'Added to bookmarks'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Revert on failure.
      if (!mounted) return;
      setState(() => _isBookmarked = current);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bookmark failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = _isBookmarked;
    if (saved == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    return IconButton(
      icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
      onPressed: _toggle,
      tooltip: saved ? 'Remove bookmark' : 'Add bookmark',
    );
  }
}

// ─────────────────────────────────────────────────────────
// 1. Header — logo + name + ticker + city/country
// ─────────────────────────────────────────────────────────

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ استخدم CompanyLogo بدلاً من CircleAvatar القديم
          CompanyLogo(
            domain: company.domain,
            name: company.commonName,
            size: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.officialName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${company.headquartersCity}, ${company.headquartersCountry}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.textSubtle,
                  ),
                ),
                if (company.tickerSymbol != null) ...[
                  const SizedBox(height: 8),
                  _TickerBadge(symbol: company.tickerSymbol!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// حذفنا _CompanyLogo القديم لأنه لم يعد مستخدماً

class _TickerBadge extends StatelessWidget {
  const _TickerBadge({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 2. Stats — CEO, founded, employees, revenue, market cap
// ─────────────────────────────────────────────────────────

class _StatsBlock extends StatelessWidget {
  const _StatsBlock({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    final rows = <_StatRow>[];

    if (company.currentCeo != null) {
      rows.add(_StatRow(label: 'CEO', value: company.currentCeo!));
    }
    rows.add(_StatRow(label: 'Founded', value: '${company.foundedYear}'));
    if (company.employeeCount != null) {
      final year = company.employeeCountYear;
      final formatted =
          NumberFormat.decimalPattern().format(company.employeeCount);
      rows.add(_StatRow(
        label: 'Employees',
        value: year == null ? formatted : '$formatted ($year)',
      ));
    }
    if (company.revenueUsd != null) {
      final year = company.revenueYear;
      final formatted = _formatLargeMoney(company.revenueUsd!);
      rows.add(_StatRow(
        label: 'Revenue',
        value: year == null ? formatted : '$formatted ($year)',
      ));
    }
    if (company.marketCapUsd != null) {
      rows.add(_StatRow(
        label: 'Market Cap',
        value: _formatLargeMoney(company.marketCapUsd!),
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  /// Formats large USD amounts as compact strings (e.g. $22.7B, $850M).
  static String _formatLargeMoney(int amount) {
    if (amount >= 1000000000000) {
      return '\$${(amount / 1000000000000).toStringAsFixed(2)}T';
    }
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    }
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(0)}M';
    }
    return '\$${NumberFormat.decimalPattern().format(amount)}';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: context.textSubtle,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 3. About — primary focus + short description
// ─────────────────────────────────────────────────────────

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Primary Focus'),
          Text(
            company.primaryFocus,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'About'),
          Text(
            company.shortDescription,
            style: TextStyle(
                fontSize: 14, height: 1.5, color: context.textMedium),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 4 & 5. Chips — technologies / customers
// ─────────────────────────────────────────────────────────

class _ChipsBlock extends StatelessWidget {
  const _ChipsBlock({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                Chip(
                  label: Text(item),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 6. Founders — list of names
// ─────────────────────────────────────────────────────────

class _FoundersBlock extends StatelessWidget {
  const _FoundersBlock({required this.founders});
  final List<String> founders;

  @override
  Widget build(BuildContext context) {
    if (founders.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Founders'),
          Text(
            founders.join(', '),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 7. Actions — careers + website buttons
// ─────────────────────────────────────────────────────────

class _ActionsBlock extends StatelessWidget {
  const _ActionsBlock({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    final hasCareers = company.careersUrl != null && company.careersUrl!.isNotEmpty;
    final hasWebsite =
        company.officialWebsite != null && company.officialWebsite!.isNotEmpty;

    if (!hasCareers && !hasWebsite) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasCareers)
            ElevatedButton.icon(
              onPressed: () => _launchExternal(context, company.careersUrl!),
              icon: const Icon(Icons.work_outline),
              label: const Text('Visit Careers Page'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          if (hasCareers && hasWebsite) const SizedBox(height: 12),
          if (hasWebsite)
            OutlinedButton.icon(
              onPressed: () => _launchExternal(context, company.officialWebsite!),
              icon: const Icon(Icons.language),
              label: const Text('Official Website'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
        ],
      ),
    );
  }

  /// Opens the URL in the device's default browser.
  /// Shows a SnackBar if the launch fails.
  Future<void> _launchExternal(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────
// Shared — section header with consistent styling
// ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}