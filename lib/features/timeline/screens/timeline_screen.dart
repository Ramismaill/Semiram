// lib/features/timeline/screens/timeline_screen.dart
//
// Chronological history of the semiconductor industry.
//
// Loads all events from EventsRepository, ordered ASC by event_date.
// Each event renders as a tile with:
//   - Left rail: year (large, accent-colored)
//   - Right content: title, description, category chip, MAJOR badge
//
// After the last event, a "TODAY" marker is rendered to anchor
// the timeline in the present moment.

import 'package:flutter/material.dart';

import '../../../core/models/industry_event.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/repositories/events_repository.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late final Future<List<IndustryEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = EventsRepository.instance.getAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: FutureBuilder<List<IndustryEvent>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString());
          }
          final events = snapshot.data ?? const <IndustryEvent>[];
          if (events.isEmpty) return const _EmptyView();
          return _TimelineList(events: events);
        },
      ),
    );
  }
}

// -----------------------------------------------------------
// States
// -----------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No events in the timeline.',
        style: TextStyle(color: context.textSubtle),
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
              'Failed to load timeline',
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

// -----------------------------------------------------------
// Main content
// -----------------------------------------------------------

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.events});
  final List<IndustryEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CountBanner(count: events.length),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            // +1 for the TODAY marker rendered after the last event.
            itemCount: events.length + 1,
            separatorBuilder: (context, index) {
              // Skip the divider that would appear right before the
              // TODAY marker — the marker is its own divider.
              if (index == events.length - 1) {
                return const SizedBox.shrink();
              }
              return const Divider(height: 1, indent: 90);
            },
            itemBuilder: (context, index) {
              if (index == events.length) {
                return const _TodayMarker();
              }
              return _EventTile(event: events[index]);
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
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semiconductor industry milestones',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.textMedium,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count == 1 ? 'event' : 'events',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------
// TODAY marker — anchors the timeline in the present moment.
// Design: thin divider lines + small gold dot + low-contrast label.
// Restrained on purpose — no glow, no badge, no card.
// -----------------------------------------------------------

class _TodayMarker extends StatelessWidget {
  const _TodayMarker();

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: gold.withValues(alpha: 0.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'TODAY  ·  MAY 2026',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: gold.withValues(alpha: 0.85),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: gold.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final IndustryEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left rail - year
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${event.year}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Right content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.eventTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (event.isMajor)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Icon(
                          Icons.star,
                          size: 16,
                          color: context.cs.primary,
                        ),
                      ),
                  ],
                ),
                if (event.eventDescription != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    event.eventDescription!,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textMedium,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (event.eventCategory != null)
                      _CategoryChip(category: event.eventCategory!),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.formattedDate(),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textFaint,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
