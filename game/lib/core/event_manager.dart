import 'dart:math';
import 'game_state.dart';

enum EventType { positive, negative, neutral }

class GameEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final void Function(GameState) apply;

  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.apply,
  });
}

class EventManager {
  final Random _rng = Random();
  double _timeSinceLastEvent = 0;
  final double _eventInterval = 60.0; // Average every 60 seconds

  // List of possible events
  final List<GameEvent> _events = [
    GameEvent(
      id: 'solar_flare',
      title: 'Solar Flare',
      description: 'Incoming solar activity! +100 Energy.',
      type: EventType.positive,
      apply: (state) {
        state.applyEventEffect({'energy': 100.0});
      },
    ),
    GameEvent(
      id: 'meteor_shower',
      title: 'Meteor Shower',
      description: 'A meteor struck! +50 Iron.',
      type: EventType.positive,
      apply: (state) {
        state.applyEventEffect({'iron': 50.0});
      },
    ),
    GameEvent(
      id: 'supply_drop',
      title: 'Supply Drop',
      description: 'Federation supplies arrived. +50 Food/Water.',
      type: EventType.positive,
      apply: (state) {
        state.applyEventEffect({'food': 50.0, 'water': 50.0});
      },
    ),
    GameEvent(
      id: 'leak',
      title: 'Water Leak',
      description: 'Pipe burst! -30 Water.',
      type: EventType.negative,
      apply: (state) {
        state.applyEventEffect({'water': -30.0});
      },
    ),
  ];

  GameEvent? checkForEvents(double dt) {
    _timeSinceLastEvent += dt;

    // Simple random check
    if (_timeSinceLastEvent > _eventInterval) {
      if (_rng.nextDouble() < 0.3) {
        // 30% chance after interval
        _timeSinceLastEvent = 0;
        final event = _events[_rng.nextInt(_events.length)];
        return event;
      }
    }
    return null;
  }
}
