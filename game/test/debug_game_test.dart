import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('Debug: Check GameScreen state changes', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: GameScreen(),
      ),
    );
    await t.pump();

    print('BEFORE TAP:');
    print('Level 1 exists: ${t.any(find.text('Level 1 - Onboarding'))}');
    print('Level 2 exists: ${t.any(find.text('Level 2 - First Choice'))}');
    print('Complete button exists: ${t.any(find.byKey(const ValueKey('complete-action')))}');

    final completeButton = find.byKey(const ValueKey('complete-action'));
    await t.ensureVisible(completeButton);
    await t.pump(const Duration(milliseconds: 100));
    await t.tap(completeButton, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 100));
    await t.pump(const Duration(milliseconds: 100));

    print('AFTER TAP:');
    print('Level 1 exists: ${t.any(find.text('Level 1 - Onboarding'))}');
    print('Level 2 exists: ${t.any(find.text('Level 2 - First Choice'))}');

    // Print all text widgets
    final allText = find.byType(Text);
    print('All text widgets:');
    for (final widget in t.widgetList(allText)) {
      if (widget is Text) {
        final data = widget.data?.toString();
        if (data != null && data.contains('Level')) {
          print('  Found: $data');
        }
      }
    }
  });
}
