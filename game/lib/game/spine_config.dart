import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Colony Commander ─────────────────────────────────────────

const kColonyCommanderMeta = SpineAssetMeta(
  key: 'colony_commander',
  path: 'spine/characters/colony_commander',
  atlasPath:
      'assets/spine/characters/colony_commander/colony_commander.atlas',
  skeletonPath:
      'assets/spine/characters/colony_commander/colony_commander.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Colony Engineer ──────────────────────────────────────────

const kColonyEngineerMeta = SpineAssetMeta(
  key: 'colony_engineer',
  path: 'spine/characters/colony_engineer',
  atlasPath:
      'assets/spine/characters/colony_engineer/colony_engineer.atlas',
  skeletonPath:
      'assets/spine/characters/colony_engineer/colony_engineer.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Colony Scout ─────────────────────────────────────────────

const kColonyScoutMeta = SpineAssetMeta(
  key: 'colony_scout',
  path: 'spine/characters/colony_scout',
  atlasPath:
      'assets/spine/characters/colony_scout/colony_scout.atlas',
  skeletonPath:
      'assets/spine/characters/colony_scout/colony_scout.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);
