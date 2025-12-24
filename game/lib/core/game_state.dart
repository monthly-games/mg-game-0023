import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/building_model.dart';
import 'event_manager.dart';

class GameState extends ChangeNotifier {
  // Resources
  double _iron = 0;
  double _water = 0;
  double _oxygen = 0;
  double _energy = 0;
  double _food = 0;
  double _research = 0;

  // Buildings
  List<Building> _buildings = [];

  // Meta
  List<String> _unlockedTechs = [];
  bool _isCrisis = false;

  // Colony Metrics
  int _population = 10;

  // Storage Caps
  final Map<String, double> _maxResources = {
    'iron': 100,
    'water': 100,
    'oxygen': 100,
    'energy': 100,
    'food': 100,
    'research': 10000, // High cap for research
  };

  // Getters
  double get iron => _iron;
  double get water => _water;
  double get oxygen => _oxygen;
  double get energy => _energy;
  double get food => _food;
  double get research => _research;
  int get population => _population;
  List<Building> get buildings => List.unmodifiable(_buildings);
  List<String> get unlockedTechs => List.unmodifiable(_unlockedTechs);
  bool get isCrisis => _isCrisis;

  double getMax(String resource) => _maxResources[resource] ?? 100;

  // Constructor
  GameState() {
    // Initial Resources
    _iron = 50;
    _water = 50;
    _oxygen = 50;
    _energy = 50;
    _food = 50;
  }

  // Helper to access resource maps dynamically
  double _getResource(String key) {
    switch (key) {
      case 'iron':
        return _iron;
      case 'water':
        return _water;
      case 'oxygen':
        return _oxygen;
      case 'energy':
        return _energy;
      case 'food':
        return _food;
      case 'research':
        return _research;
      default:
        return 0;
    }
  }

  // Core Game Loop
  void update(double dt) {
    // Calculate Production/Consumption per tick (dt in seconds)

    double ironChange = 0;
    double waterChange = 0;
    double oxygenChange = 0;
    double energyChange = 0;
    double foodChange = 0;
    double researchChange = 0;

    // 1. Calculate Max Capacity based on buildings
    // Reset to base
    _maxResources.updateAll((key, val) => key == 'research' ? 10000.0 : 100.0);
    for (var building in _buildings) {
      building.storageIncrease.forEach((res, amount) {
        _maxResources[res] = (_maxResources[res] ?? 100) + amount;
      });
    }

    // 2. Building Logic
    for (var building in _buildings) {
      if (!building.isActive) continue;

      // check Inputs
      bool hasInputs = true;
      building.consumption.forEach((res, rate) {
        if (_getResource(res) < rate * dt) {
          hasInputs = false;
        }
      });

      // Check Outputs (Storage Full?)
      bool outputsFull = false;
      building.production.forEach((res, rate) {
        if (_getResource(res) >= (_maxResources[res] ?? 100)) {
          outputsFull = true;
        }
      });

      if (!hasInputs || outputsFull) continue;

      // Process Production
      ironChange += (building.production['iron'] ?? 0) * dt;
      waterChange += (building.production['water'] ?? 0) * dt;
      oxygenChange += (building.production['oxygen'] ?? 0) * dt;
      energyChange += (building.production['energy'] ?? 0) * dt;
      foodChange += (building.production['food'] ?? 0) * dt;
      researchChange += (building.production['research'] ?? 0) * dt;

      // Process Consumption
      ironChange -= (building.consumption['iron'] ?? 0) * dt;
      waterChange -= (building.consumption['water'] ?? 0) * dt;
      oxygenChange -= (building.consumption['oxygen'] ?? 0) * dt;
      energyChange -= (building.consumption['energy'] ?? 0) * dt;
      foodChange -= (building.consumption['food'] ?? 0) * dt;
      researchChange -= (building.consumption['research'] ?? 0) * dt;
    }

    // 3. Survival Consumption (Population)
    double consumptionRate = 0.1;

    if (_food > 0) foodChange -= _population * consumptionRate * dt;
    if (_water > 0) waterChange -= _population * consumptionRate * dt;
    if (_oxygen > 0) oxygenChange -= _population * consumptionRate * dt;

    // Apply Changes & Clamp
    _iron = (_iron + ironChange).clamp(0.0, _maxResources['iron']!);
    _water = (_water + waterChange).clamp(0.0, _maxResources['water']!);
    _oxygen = (_oxygen + oxygenChange).clamp(0.0, _maxResources['oxygen']!);
    _energy = (_energy + energyChange).clamp(0.0, _maxResources['energy']!);
    _food = (_food + foodChange).clamp(0.0, _maxResources['food']!);
    _research = (_research + researchChange).clamp(
      0.0,
      _maxResources['research']!,
    );

    // 4. Crisis Check
    _isCrisis = (_food <= 0 || _water <= 0 || _oxygen <= 0);

    // 5. Event Check
    final event = _eventManager.checkForEvents(dt);
    if (event != null) {
      _lastEventMessage = '${event.title}: ${event.description}';
      event.apply(this);
    }

    notifyListeners();
  }

  // Event Support
  final EventManager _eventManager = EventManager();
  String? _lastEventMessage;
  String? get lastEventMessage => _lastEventMessage;

  void clearEventMessage() {
    _lastEventMessage = null;
    notifyListeners();
  }

  void applyEventEffect(Map<String, double> resourceChanges) {
    resourceChanges.forEach((res, amount) {
      if (res == 'iron')
        _iron = (_iron + amount).clamp(0.0, _maxResources['iron']!);
      if (res == 'water')
        _water = (_water + amount).clamp(0.0, _maxResources['water']!);
      if (res == 'oxygen')
        _oxygen = (_oxygen + amount).clamp(0.0, _maxResources['oxygen']!);
      if (res == 'energy')
        _energy = (_energy + amount).clamp(0.0, _maxResources['energy']!);
      if (res == 'food')
        _food = (_food + amount).clamp(0.0, _maxResources['food']!);
      if (res == 'research')
        _research = (_research + amount).clamp(0.0, _maxResources['research']!);
    });
    notifyListeners();
  }

  void addBuilding(Building building) {
    _buildings.add(building);
    notifyListeners();
  }

  // Test/Cheat helper
  void addResearch(double amount) {
    _research += amount;
    notifyListeners();
  }

  bool unlockTech(String techId) {
    // Hardcoded cost for prototype: 10
    double cost = 10.0;
    if (_research >= cost && !_unlockedTechs.contains(techId)) {
      _research -= cost;
      _unlockedTechs.add(techId);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'iron': _iron,
      'water': _water,
      'oxygen': _oxygen,
      'energy': _energy,
      'food': _food,
      'research': _research,
      'population': _population,
      'unlockedTechs': _unlockedTechs,
      'buildings': _buildings.map((b) => b.toJson()).toList(),
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    _iron = (json['iron'] as num?)?.toDouble() ?? 50.0;
    _water = (json['water'] as num?)?.toDouble() ?? 50.0;
    _oxygen = (json['oxygen'] as num?)?.toDouble() ?? 50.0;
    _energy = (json['energy'] as num?)?.toDouble() ?? 50.0;
    _food = (json['food'] as num?)?.toDouble() ?? 50.0;
    _research = (json['research'] as num?)?.toDouble() ?? 0.0;
    _population = (json['population'] as num?)?.toInt() ?? 10;

    _unlockedTechs = List<String>.from(json['unlockedTechs'] ?? []);

    if (json['buildings'] != null) {
      _buildings = (json['buildings'] as List)
          .map((b) => Building.fromJson(b as Map<String, dynamic>))
          .toList();
    } else {
      _buildings = [];
    }
    notifyListeners();
  }
}
