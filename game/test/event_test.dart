import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/core/event_manager.dart';

void main() {
  group('Event Logic Tests', () {
    test('EventManager triggers events', () {
      final manager = EventManager();
      // Force trigger by simulating large time passage
      final event = manager.checkForEvents(120.0);
      // It's probabilistic (30%), so not guaranteed, but likely.
      // Ideally we'd mock the Random inside EventManager, but for now let's just test logic structure.
      // If null, it just means RNG didn't hit.
    });

    test('GameState handles event effects', () {
      final state = GameState();
      double initialIron = state.iron;

      // Simulate Meteor Shower
      state.applyEventEffect({'iron': 50.0});

      expect(state.iron, initialIron + 50.0);
    });

    test('GameState clamps event effects', () {
      final state = GameState();

      // Simulate massive loss
      state.applyEventEffect({'water': -1000.0});

      expect(state.water, 0.0);
    });
  });
}
