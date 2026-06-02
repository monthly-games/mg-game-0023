import '../models/building_model.dart';

/// 건물 배치 시너지 시스템 - 전략적 깊이 추가
class SynergySystem {
  static const double _adjacentBonus = 0.15; // 인접 보너스 15%
  static const double _clusterBonus = 0.25; // 클러스터 보너스 25%
  static const int _clusterSize = 3; // 클러스터 크기

  /// 건물의 시너지 보너스 계산
  static SynergyResult calculateSynergy(
    Building building,
    List<Building> allBuildings,
  ) {
    double totalBonus = 1.0;
    final List<String> activeSynergies = [];

    // 1. 인접 건물 보너스 (같은 타입)
    final sameTypeAdjacent = _getAdjacentBuildings(building, allBuildings)
        .where((b) => b.type == building.type)
        .length;

    if (sameTypeAdjacent > 0) {
      final bonus = 1.0 + (sameTypeAdjacent * _adjacentBonus);
      totalBonus *= bonus;
      activeSynergies.add('Adjacent x$sameTypeAdjacent (+${((bonus - 1) * 100).toInt()}%)');
    }

    // 2. 클러스터 보너스 (3개 이상 모여있을 때)
    final clusterSize = _getClusterSize(building, allBuildings);
    if (clusterSize >= _clusterSize) {
      totalBonus *= (1.0 + _clusterBonus);
      activeSynergies.add('Cluster of $clusterSize (+${(_clusterBonus * 100).toInt()}%)');
    }

    // 3. 특수 시너지 조합
    final specialSynergy = _checkSpecialSynergy(building, allBuildings);
    if (specialSynergy != null) {
      totalBonus *= specialSynergy.bonus;
      activeSynergies.add(specialSynergy.name);
    }

    return SynergyResult(
      totalBonus: totalBonus,
      activeSynergies: activeSynergies,
    );
  }

  /// 인접한 건물들 찾기 (8방향)
  static List<Building> _getAdjacentBuildings(
    Building building,
    List<Building> allBuildings,
  ) {
    return allBuildings.where((b) {
      if (b.id == building.id) return false;
      final dx = (b.gridX - building.gridX).abs();
      final dy = (b.gridY - building.gridY).abs();
      return dx <= 1 && dy <= 1;
    }).toList();
  }

  /// 클러스터 크기 계산 (같은 타입이 연속적으로 모여있는지)
  static int _getClusterSize(Building building, List<Building> allBuildings) {
    final sameType = allBuildings.where((b) => b.type == building.type).toList();
    if (sameType.isEmpty) return 0;

    // BFS로 연결된 같은 타입 건물 수 계산
    final visited = <String>{};
    final queue = <Building>[building];
    int count = 0;

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current.id)) continue;
      visited.add(current.id);
      count++;

      final adjacent = _getAdjacentBuildings(current, sameType);
      for (final adj in adjacent) {
        if (!visited.contains(adj.id)) {
          queue.add(adj);
        }
      }
    }

    return count;
  }

  /// 특수 시너지 조합 체크
  static SpecialSynergy? _checkSpecialSynergy(
    Building building,
    List<Building> allBuildings,
  ) {
    final adjacent = _getAdjacentBuildings(building, allBuildings);

    // Energy + Water = Hydro Power Bonus
    if (building.type == 'Energy') {
      final hasWater = adjacent.any((b) => b.type == 'Water');
      if (hasWater) {
        return const SpecialSynergy(
          name: 'Hydro Power Synergy (+20%)',
          bonus: 1.2,
        );
      }
    }

    // Research + Research = Knowledge Sharing
    if (building.type == 'Research') {
      final researchCount = adjacent.where((b) => b.type == 'Research').length;
      if (researchCount >= 2) {
        return const SpecialSynergy(
          name: 'Knowledge Sharing (+30%)',
          bonus: 1.3,
        );
      }
    }

    // Storage + Producer = Efficient Storage
    if (building.type == 'Storage') {
      final hasProducer = adjacent.any((b) =>
        b.production.isNotEmpty && b.type != 'Storage');
      if (hasProducer) {
        return const SpecialSynergy(
          name: 'Efficient Storage (+10%)',
          bonus: 1.1,
        );
      }
    }

    return null;
  }
}

/// 시너지 결과
class SynergyResult {
  final double totalBonus;
  final List<String> activeSynergies;

  const SynergyResult({
    required this.totalBonus,
    required this.activeSynergies,
  });
}

/// 특수 시너지
class SpecialSynergy {
  final String name;
  final double bonus;

  const SpecialSynergy({
    required this.name,
    required this.bonus,
  });
}
