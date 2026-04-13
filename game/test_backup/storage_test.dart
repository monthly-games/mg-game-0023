import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/models/building_model.dart';

void main() {
  group('Storage & Chain Tests', () {
    test('Production halts if inputs missing', () {
      final state = GameState();

      // Set Iron to 0 manually for test (need setter or re-init approach, assume default 100)
      // Since resources are private with getters only, we need a way to consume them or init state.
      // GameState doesn't have sets. Let's consume all iron first.
      // Or better, let's assume we can add a helper or rely on logic.
      // Actually, let's create a GameState with custom resources if possible, or consume it.

      // Let's add a "Consumer" building to drain Iron quickly.
      state.addBuilding(
        const Building(
          id: 'consumer',
          name: 'Void',
          type: 'Test',
          consumption: {'iron': 50.0}, // Drain exactly 50 in 1 sec
        ),
      );

      state.update(1.0);
      expect(state.iron, 0);

      // Now add a "Producer" that needs Iron to make "Steel"
      // Note: "Steel" isn't a core resource in the initial list, using 'energy' as output for test
      // Input: Iron, Output: Energy
      state.addBuilding(
        const Building(
          id: 'converter',
          name: 'Iron Burner',
          type: 'Test',
          consumption: {'iron': 1.0},
          production: {'energy': 10.0},
        ),
      );

      double energyBefore = state.energy;

      // Update. Should NOT produce energy because Iron is 0.
      state.update(1.0);

      expect(state.energy, energyBefore);
      expect(state.iron, 0);
    });

    test('Production halts if storage full', () {
      final state = GameState();
      // Assume Max Water is 100 by default.

      // Fill Water to Max
      state.addBuilding(
        const Building(
          id: 'water_pump',
          name: 'Pump',
          type: 'Water',
          production: {'water': 1000.0},
        ),
      );

      state.update(1.0);
      expect(state.water, 100.0); // Clamped at max (100)

      // Now add a building that tries to produce more water
      // It should not be able to produce (in this logic, it just clamps, but effectively "halts" net gain)
      // To test "Halt", we actully care about consumption not happening if output is full?
      // Usually: If Output Full -> Stop Working -> Stop Consuming Inputs.

      // Test: Input Energy -> Output Water.
      // If Water Full -> Energy should NOT be consumed.

      double energyStart = state.energy;

      state.addBuilding(
        const Building(
          id: 'smart_pump',
          name: 'Smart Pump',
          type: 'Water',
          consumption: {'energy': 1.0},
          production: {'water': 1.0},
        ),
      );

      // Make sure we have energy
      expect(energyStart, greaterThan(0));

      state.update(1.0);

      // Water is full (100). Smart Pump should see output full and NOT run.
      // So Energy should not decrease.
      // (Note: other buildings might affect energy, so better isolate or check delta)
      // In this test, we have 'consumer' from previous test? No, new state.
      // BUT we have 'water_pump' producing 1000 water.
      // If 'water_pump' runs, it keeps water at max.
      // 'smart_pump' checks: is water full? Yes.
      // So 'smart_pump' should idle.

      // Wait, if multiple producers exist, partial fill?
      // Logic: For each building, if (current + production > max) { produce only what fits? }
      // Or Simple: `if (current >= max) return;`
      // Let's implement the simpler "If Full, Stop" logic first.

      expect(state.energy, energyStart);
    });

    test('Storage Building increases capacity', () {
      final state = GameState();

      // Initial Max 100
      state.addBuilding(
        const Building(
          id: 'water_pump',
          name: 'Pump',
          type: 'Water',
          production: {'water': 1000.0},
        ),
      );
      state.update(1.0);
      expect(state.water, 100.0);

      // Add Silo (+100 Water Max)
      state.addBuilding(
        const Building(
          id: 'silo',
          name: 'Water Tank',
          type: 'Storage',
          storageIncrease: {'water': 100.0},
        ),
      );

      // Now max should be 200.
      state.update(1.0);
      expect(state.water, 200.0);
    });
  });
}
