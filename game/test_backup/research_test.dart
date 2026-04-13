import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/models/building_model.dart';

void main() {
  group('Research & Survival Tests', () {
    test('Lab produces Research Points', () {
      final state = GameState();

      state.addBuilding(
        const Building(
          id: 'lab',
          name: 'Lab',
          type: 'Research',
          production: {'research': 1.0},
        ),
      );

      expect(state.research, 0);
      state.update(1.0);
      expect(state.research, 1.0);
    });

    test('Unlock Tech adds to unlockedBuildingIds', () {
      final state = GameState();

      // Assume "Advanced Power" costs 10 research
      // We manually add research for test
      state.addResearch(100.0);

      bool success = state.unlockTech('tech_nuclear');

      expect(success, true);
      expect(state.unlockedTechs, contains('tech_nuclear'));
      expect(state.research, 90.0); // 100 - 10 cost
    });

    test('Survival Crisis Trigger', () {
      final state = GameState();
      // Reset food to 0
      // We need a way to set it, or drain it.
      // GameState init has 50 food.
      // Pop consumes 1.0 per sec (10 pop * 0.1).
      // So 50 seconds to drain.

      state.update(60.0);

      expect(state.food, 0);
      expect(state.isCrisis, true);
    });
  });
}
