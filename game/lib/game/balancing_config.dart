import 'package:mg_common_game/systems/balancing/balancing.dart';

/// Default balancing configuration for MG-0023: Colony Frontier.
///
/// Placeholder values -- override via RemoteConfig using
/// [BalancingManager.loadFromRemote] in production.
const kDefaultBalancingConfig = BalancingConfig(
  gameId: 'mg-0023',
  version: 1,
  currencies: [
    CurrencyConfig(id: 'gold', baseEarnRate: 10.0),
    CurrencyConfig(
      id: 'gems',
      baseEarnRate: 1.0,
      earnCurve: CurveType.logarithmic,
      earnGrowthFactor: 0.5,
    ),
  ],
  xpCurve: XpCurveConfig(baseXp: 100, maxLevel: 100),
  difficultyScaling: DifficultyScalingConfig(scalingFactor: 0.08),
  customParams: {
    'idle_rate_base': 1.0,
    'prestige_bonus': 1.5,
  },
);
