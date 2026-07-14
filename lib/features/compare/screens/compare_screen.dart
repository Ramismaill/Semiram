// lib/features/compare/screens/compare_screen.dart
//
// Side-by-side comparison of two companies.
//
// Layout:
//   1. Two DropdownButtonFormField widgets (Company A, Company B)
//   2. Stats table (Founded, HQ, CEO, Employees, Revenue, Market Cap)
//   3. Primary Focus — stacked text per company
//   4. Key Technologies — chip cloud per company
//   5. Notable Customers — chip cloud per company
//
// SQL: UNION ALL combines two single-row SELECTs into one result set,
// preserving order. See CompaniesRepository.compareTwoCompanies().

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/company.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/repositories/companies_repository.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late final Future<List<Company>> _allCompaniesFuture;
  Company? _selectedA;
  Company? _selectedB;
  Future<List<Company>>? _comparisonFuture;

  @override
  void initState() {
    super.initState();
    _allCompaniesFuture = CompaniesRepository.instance.getAllCompanies();
  }

  /// Re-runs the comparison query whenever both companies are valid
  /// (selected and distinct).
  void _refreshComparison() {
    final a = _selectedA;
    final b = _selectedB;
    if (a != null && b != null && a.id != b.id) {
      setState(() {
        _comparisonFuture = CompaniesRepository.instance.compareTwoCompanies(
          a.id,
          b.id,
        );
      });
    } else {
      setState(() => _comparisonFuture = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: FutureBuilder<List<Company>>(
        future: _allCompaniesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error loading companies: ${snapshot.error}'),
              ),
            );
          }
          final all = snapshot.data ?? const <Company>[];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SelectorsBlock(
                  all: all,
                  selectedA: _selectedA,
                  selectedB: _selectedB,
                  onChangeA: (v) {
                    setState(() => _selectedA = v);
                    _refreshComparison();
                  },
                  onChangeB: (v) {
                    setState(() => _selectedB = v);
                    _refreshComparison();
                  },
                ),
                _buildBody(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final a = _selectedA;
    final b = _selectedB;

    // Both empty — initial prompt
    if (a == null && b == null) return const _PromptView();

    // One missing — partial selection prompt
    if (a == null || b == null) return const _PartialPromptView();

    // Same selected — warning
    if (a.id == b.id) return const _SameWarningView();

    // Both valid — show comparison
    return _ComparisonResults(future: _comparisonFuture!);
  }
}

// ─────────────────────────────────────────────────────────
// Selectors (top of screen)
// ─────────────────────────────────────────────────────────

class _SelectorsBlock extends StatelessWidget {
  const _SelectorsBlock({
    required this.all,
    required this.selectedA,
    required this.selectedB,
    required this.onChangeA,
    required this.onChangeB,
  });

  final List<Company> all;
  final Company? selectedA;
  final Company? selectedB;
  final ValueChanged<Company?> onChangeA;
  final ValueChanged<Company?> onChangeB;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          _CompanyDropdown(
            label: 'Company A',
            selected: selectedA,
            companies: all,
            onChanged: onChangeA,
          ),
          const SizedBox(height: 16),
          Center(
            child: Icon(
              Icons.compare_arrows,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          _CompanyDropdown(
            label: 'Company B',
            selected: selectedB,
            companies: all,
            onChanged: onChangeB,
          ),
        ],
      ),
    );
  }
}

class _CompanyDropdown extends StatelessWidget {
  const _CompanyDropdown({
    required this.label,
    required this.selected,
    required this.companies,
    required this.onChanged,
  });

  final String label;
  final Company? selected;
  final List<Company> companies;
  final ValueChanged<Company?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Company>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      hint: const Text('Select a company'),
      items: companies
          .map(
            (c) => DropdownMenuItem<Company>(
              value: c,
              child: Text(
                c.commonName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────
// Body states
// ─────────────────────────────────────────────────────────

class _PromptView extends StatelessWidget {
  const _PromptView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows,
            size: 56,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Pick two companies to compare',
            style: TextStyle(fontSize: 16, color: context.textSubtle),
          ),
        ],
      ),
    );
  }
}

class _PartialPromptView extends StatelessWidget {
  const _PartialPromptView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Text(
        'Select the second company',
        style: TextStyle(fontSize: 14, color: context.textSubtle),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SameWarningView extends StatelessWidget {
  const _SameWarningView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: context.cs.tertiary),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Please select two different companies',
              style: TextStyle(color: context.cs.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Comparison results
// ─────────────────────────────────────────────────────────

class _ComparisonResults extends StatelessWidget {
  const _ComparisonResults({required this.future});
  final Future<List<Company>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Company>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final result = snapshot.data ?? const <Company>[];
        if (result.length < 2) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Text('One or both companies not found.'),
          );
        }
        return _ComparisonTable(a: result[0], b: result[1]);
      },
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.a, required this.b});
  final Company a;
  final Company b;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          _StatHeader(a: a.commonName, b: b.commonName),
          const SizedBox(height: 8),
          _StatRow(label: 'Founded', a: '${a.foundedYear}', b: '${b.foundedYear}'),
          _StatRow(
            label: 'Country',
            a: a.headquartersCountry,
            b: b.headquartersCountry,
          ),
          if (a.currentCeo != null || b.currentCeo != null)
            _StatRow(
              label: 'CEO',
              a: a.currentCeo ?? '—',
              b: b.currentCeo ?? '—',
            ),
          if (a.employeeCount != null || b.employeeCount != null)
            _StatRow(
              label: 'Employees',
              a: _formatCount(a.employeeCount),
              b: _formatCount(b.employeeCount),
            ),
          if (a.revenueUsd != null || b.revenueUsd != null)
            _StatRow(
              label: 'Revenue',
              a: _formatMoney(a.revenueUsd),
              b: _formatMoney(b.revenueUsd),
            ),
          if (a.marketCapUsd != null || b.marketCapUsd != null)
            _StatRow(
              label: 'Market Cap',
              a: _formatMoney(a.marketCapUsd),
              b: _formatMoney(b.marketCapUsd),
            ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Primary Focus'),
          _LabeledText(label: a.commonName, text: a.primaryFocus),
          const SizedBox(height: 12),
          _LabeledText(label: b.commonName, text: b.primaryFocus),
          if (a.keyTechnologies.isNotEmpty || b.keyTechnologies.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Key Technologies'),
            _LabeledChips(label: a.commonName, items: a.keyTechnologies),
            const SizedBox(height: 12),
            _LabeledChips(label: b.commonName, items: b.keyTechnologies),
          ],
          if (a.notableCustomers.isNotEmpty || b.notableCustomers.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Notable Customers'),
            _LabeledChips(label: a.commonName, items: a.notableCustomers),
            const SizedBox(height: 12),
            _LabeledChips(label: b.commonName, items: b.notableCustomers),
          ],
        ],
      ),
    );
  }

  static String _formatMoney(int? amount) {
    if (amount == null) return '—';
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

  static String _formatCount(int? count) {
    if (count == null) return '—';
    return NumberFormat.decimalPattern().format(count);
  }
}

// ─────────────────────────────────────────────────────────
// Reusable presentation pieces
// ─────────────────────────────────────────────────────────

class _StatHeader extends StatelessWidget {
  const _StatHeader({required this.a, required this.b});
  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: Theme.of(context).colorScheme.primary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 110),
          Expanded(child: Text(a, style: style)),
          Expanded(child: Text(b, style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.a, required this.b});
  final String label;
  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              a,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              b,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

class _LabeledText extends StatelessWidget {
  const _LabeledText({required this.label, required this.text});
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textMedium,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

class _LabeledChips extends StatelessWidget {
  const _LabeledChips({required this.label, required this.items});
  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            '—',
            style: TextStyle(color: context.textFaint, fontSize: 13),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in items)
                Chip(
                  label: Text(item),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                  ),
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
      ],
    );
  }
}
