import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gameplay Fun Element Inspection', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('1. Skip intro and verify main menu', () async {
      // Wait for app to load
      await Future.delayed(const Duration(seconds: 2));

      // Tap to skip intro
      await driver.tap(find.text('탭하여 시작'));
      await Future.delayed(const Duration(seconds: 2));

      // Verify main menu elements
      expect(await driver.getText(find.text('MG-0023')), 'MG-0023');
      expect(await driver.getText(find.text('COLONY FRONTIER')), 'COLONY FRONTIER');
    });

    test('2. Start game and verify game screen elements', () async {
      // Start game
      await driver.tap(find.byValueKey('start-game'));
      await Future.delayed(const Duration(seconds: 2));

      // Verify game screen
      expect(await driver.getText(find.text('Live Run')), 'Live Run');

      // Take screenshot of game screen
      await driver.screenshot('game_screen_initial');
    });

    test('3. Complete action and verify progression', () async {
      // Find and tap complete action button
      await driver.scrollUntilVisible(
        find.byValueKey('complete-action'),
        find.byType('ListView'),
      );

      await driver.tap(find.byValueKey('complete-action'));
      await Future.delayed(const Duration(seconds: 1));

      // Verify level advanced
      await driver.waitFor(find.textContaining('Level 2'));

      // Take screenshot after progression
      await driver.screenshot('after_level_2');
    });

    test('4. Complete multiple levels and verify rewards', () async {
      // Complete levels 2-4
      for (int i = 0; i < 3; i++) {
        await driver.tap(find.byValueKey('complete-action'));
        await Future.delayed(const Duration(seconds: 1));
      }

      // Verify accumulated rewards
      await driver.waitFor(find.textContaining('gold'));
      await driver.waitFor(find.textContaining('xp'));

      // Take screenshot showing rewards
      await driver.screenshot('rewards_accumulated');
    });

    test('5. Verify difficulty progression', () async {
      // Check difficulty display
      final difficultyText = await driver.getText(find.textContaining('Difficulty'));
      print('Current difficulty: $difficultyText');

      // Verify enemy count display
      await driver.waitFor(find.textContaining('targets'));
      final targetsText = await driver.getText(find.textContaining('targets'));
      print('Enemy count: $targetsText');

      await driver.screenshot('difficulty_display');
    });
  });
}
