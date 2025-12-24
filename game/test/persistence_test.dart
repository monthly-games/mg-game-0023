import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/models/building_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/core/persistence_manager.dart';

void main() {
  group('Persistence Tests', () {
    test('GameState Serialization Cycle', () {
      final state = GameState();

      // Modify state
      state.addResearch(500);
      state.unlockTech('tech_test');
      state.addBuilding(
        const Building(
          id: 'b_test',
          name: 'Test Building',
          type: 'Producer',
          isActive: true,
        ),
      );

      // Serialize
      final json = state.toJson();

      // Create new state and load
      final newState = GameState();
      newState.loadFromJson(json);

      // Verify
      expect(newState.research, 490);
      expect(newState.unlockedTechs, contains('tech_test'));
      expect(newState.buildings.length, 1);
      expect(newState.buildings.first.id, 'b_test');
    });

    test('PersistenceManager Save/Load', () async {
      SharedPreferences.setMockInitialValues({});

      final manager = PersistenceManager();
      final state = GameState();
      state.addResearch(123);

      // Save
      await manager.saveGame(state);

      // Reset state
      final newState = GameState();
      expect(newState.research, 0); // Should be 0 initially

      // Load
      bool success = await manager.loadGame(newState);
      expect(success, true);
      expect(newState.research, 123);
    });
  });
}
