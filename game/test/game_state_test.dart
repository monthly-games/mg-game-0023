import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/models/building_model.dart';

void main() {
  group('GameState Tests', () {
    test('Initial resources are set', () {
      final state = GameState();
      expect(state.iron, 50);
      expect(state.population, 10);
    });

    test('Consumption checks - Population consumes resources', () {
      final state = GameState();
      double initialFood = state.food;

      state.update(1.0); // 1 second tick

      expect(
        state.food,
        lessThan(initialFood),
      ); // Should decrease due to population
    });

    test('Building Production works', () {
      final state = GameState();

      // Add Solar Panel (Energy +1/s)
      state.addBuilding(
        const Building(
          id: 'b1',
          name: 'Solar Panel',
          type: 'Energy',
          production: {'energy': 1.0},
        ),
      );

      double initialEnergy = state.energy;
      state.update(1.0);

      // Initial + Production - Consumption
      // Consumption is 0 for energy by pop (in current logic)
      expect(state.energy, initialEnergy + 1.0);
    });
  });
}
