// Basic smoke test: the app builds and shows the Semiram title.

import 'package:flutter_test/flutter_test.dart';

import 'package:semiram/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SemiramApp());
    expect(find.text('Semiram'), findsOneWidget);
  });
}
