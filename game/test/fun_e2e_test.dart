import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/ui/animated_main_menu.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = false;

  testWidgets('MG-0023 fun e2e: AnimatedMainMenu elements exist', (tester) async {
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

    // Wait for animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify main menu elements
    expect(find.text('MG-0023'), findsOneWidget);
    expect(find.text('COLONY FRONTIER'), findsOneWidget);

    // Verify all key menu buttons exist
    expect(find.byKey(const ValueKey('play-colony')), findsOneWidget);
    expect(find.byKey(const ValueKey('start-game')), findsOneWidget);
    expect(find.byKey(const ValueKey('level-roadmap')), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial')), findsOneWidget);
    expect(find.byKey(const ValueKey('daily-quests')), findsOneWidget);
    expect(find.byKey(const ValueKey('rewards')), findsOneWidget);
  });

  testWidgets('MG-0023 fun e2e: Daily quests and rewards accessible', (tester) async {
    String? screenContent;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedMainMenu(
            onPlayColony: () {},
            onStartGame: () {},
            onLevels: () {},
            onTutorial: () {},
            onRewards: () {
              screenContent = '보상';
            },
            onDaily: () {
              screenContent = '데일리';
            },
            onBattle: () {},
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    // Quick actions are at the bottom, need to scroll or ensure visible
    final dailyQuestsButton = find.byKey(const ValueKey('daily-quests'));
    await tester.ensureVisible(dailyQuestsButton);
    await tester.pump(const Duration(milliseconds: 100));

    // Test Daily Quests
    await tester.tap(dailyQuestsButton, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(screenContent, '데일리');

    // Test Rewards
    final rewardsButton = find.byKey(const ValueKey('rewards'));
    await tester.ensureVisible(rewardsButton);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(rewardsButton, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(screenContent, '보상');
  });
}
