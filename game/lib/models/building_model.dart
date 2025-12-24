import 'package:equatable/equatable.dart';

class Building extends Equatable {
  final String id;
  final String name;
  final String type; // Producer, Consumer, Utility
  final Map<String, double> production; // resource: rate per sec
  final Map<String, double> consumption; // resource: rate per sec
  final Map<String, double> storageIncrease; // resource: amount
  final String? requiredTech; // Tech ID needed to build
  final bool isActive;

  const Building({
    required this.id,
    required this.name,
    required this.type,
    this.production = const {},
    this.consumption = const {},
    this.storageIncrease = const {},
    this.requiredTech,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'production': production,
      'consumption': consumption,
      'storageIncrease': storageIncrease,
      'requiredTech': requiredTech,
      'isActive': isActive,
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      production: Map<String, double>.from(json['production'] ?? {}),
      consumption: Map<String, double>.from(json['consumption'] ?? {}),
      storageIncrease: Map<String, double>.from(json['storageIncrease'] ?? {}),
      requiredTech: json['requiredTech'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    production,
    consumption,
    storageIncrease,
    requiredTech,
    isActive,
  ];
}
