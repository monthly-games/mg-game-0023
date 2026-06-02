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
  final int gridX; // 그리드 X 위치 (시너지 계산용)
  final int gridY; // 그리드 Y 위치 (시너지 계산용)

  const Building({
    required this.id,
    required this.name,
    required this.type,
    this.production = const {},
    this.consumption = const {},
    this.storageIncrease = const {},
    this.requiredTech,
    this.isActive = true,
    this.gridX = 0,
    this.gridY = 0,
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
      'gridX': gridX,
      'gridY': gridY,
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
      gridX: json['gridX'] as int? ?? 0,
      gridY: json['gridY'] as int? ?? 0,
    );
  }

  Building copyWith({
    String? id,
    String? name,
    String? type,
    Map<String, double>? production,
    Map<String, double>? consumption,
    Map<String, double>? storageIncrease,
    String? requiredTech,
    bool? isActive,
    int? gridX,
    int? gridY,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      production: production ?? this.production,
      consumption: consumption ?? this.consumption,
      storageIncrease: storageIncrease ?? this.storageIncrease,
      requiredTech: requiredTech ?? this.requiredTech,
      isActive: isActive ?? this.isActive,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
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
    gridX,
    gridY,
  ];
}
