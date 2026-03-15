import 'package:flutter/foundation.dart';

/// Template for a building type
class BuildingTemplate {
  final String id;
  final String name;
  final String type;
  final Map<String, int> cost;
  final Map<String, double> production;
  final Map<String, double> consumption;
  final Map<String, int> storageIncrease;
  final int housingCapacity;
  final String? requiredTech;

  const BuildingTemplate({
    required this.id,
    required this.name,
    required this.type,
    this.cost = const {},
    this.production = const {},
    this.consumption = const {},
    this.storageIncrease = const {},
    this.housingCapacity = 0,
    this.requiredTech,
  });
}

/// Manages buildings in the colony
class BuildingManager extends ChangeNotifier {
  final Map<String, BuildingTemplate> _templates = {};
  final Map<String, int> _builtCounts = {};

  Map<String, BuildingTemplate> get templates => Map.unmodifiable(_templates);
  Map<String, int> get builtCounts => Map.unmodifiable(_builtCounts);

  void registerTemplate(BuildingTemplate template) {
    _templates[template.id] = template;
  }

  bool build(String templateId) {
    if (!_templates.containsKey(templateId)) return false;
    _builtCounts[templateId] = (_builtCounts[templateId] ?? 0) + 1;
    notifyListeners();
    return true;
  }

  int getCount(String templateId) => _builtCounts[templateId] ?? 0;
}
