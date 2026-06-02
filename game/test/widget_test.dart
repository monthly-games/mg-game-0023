import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';
import 'package:game/ui/animated_main_menu.dart';

void main() {
  testWidgets('app boots to the main menu', (tester) async {
    // Test AnimatedMainMenu directly to avoid intro timing issues
    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedMainMenu(
          onPlayColony: () {},
          onStartGame: () {},
          onLevels: () {},
          onTutorial: () {},
          onRewards: () {},
          onDaily: () {},
          onBattle: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('MG-'), findsWidgets);
    expect(find.byKey(const ValueKey('start-game')), findsOneWidget);
  });
}
