import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';
import '../core/game_state.dart';
import '../core/persistence_manager.dart';
import '../core/synergy_system.dart';
import '../core/weather_system.dart';
import '../core/meaningful_choice_system.dart';
import '../models/building_model.dart';
import '../ui/resource_view.dart';
import '../ui/sprite_clipper.dart';
import '../ui/crisis_overlay.dart';
import '../ui/colony_visualization.dart';
import '../ui/level_up_showcase.dart';
import 'battlepass_screen.dart';
import 'gacha_screen.dart';
import 'research_screen.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class ColonyScreen extends StatefulWidget {
  const ColonyScreen({super.key});

  @override
  State<ColonyScreen> createState() => _ColonyScreenState();
}

class _ColonyScreenState extends State<ColonyScreen> {
  Timer? _gameLoop;

  // 시스템들
  late WeatherSystem _weatherSystem;
  late MeaningfulChoiceSystem _choiceSystem;
  final List<ConstructionCompletionEffectData> _completionEffects = [];

  // 화면 표시 상태
  bool _showLevelUp = false;
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();

    // 시스템 초기화
    _weatherSystem = WeatherSystem()..start();
    _choiceSystem = MeaningfulChoiceSystem()..start();

    // 게임 루프 시작 (10 ticks per second)
    _gameLoop = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final gameState = context.read<GameState>();

      // 기본 업데이트
      gameState.update(0.1);

      // 날씨 효과 적용
      _weatherSystem.applyWeatherEffects(gameState);
      _weatherSystem.applyActiveEvents(gameState);

      // 레벨업 체크 (간단 구현)
      _checkLevelUp(gameState);
    });

    // BGM 재생
    FlameAudio.bgm.play('bgm_colony.mp3', volume: 0.3);
  }

  void _checkLevelUp(GameState gameState) {
    // 간단한 레벨업 로직 (연구 포인트 기반)
    final newLevel = 1 + (gameState.research / 50).floor();
    if (newLevel > _currentLevel && newLevel <= 8) {
      setState(() {
        _currentLevel = newLevel;
        _showLevelUp = true;
      });

      // 3초 후 레벨업 화면 닫기
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() => _showLevelUp = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _weatherSystem.dispose();
    _choiceSystem.dispose();
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    // 이벤트 메시지 표시
    if (gameState.lastEventMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(gameState.lastEventMessage!),
            backgroundColor: Colors.amber[900],
            duration: const Duration(seconds: 4),
          ),
        );
        context.read<GameState>().clearEventMessage();
      });
    }

    // 레벨업 오버레이
    if (_showLevelUp) {
      return Scaffold(
        body: LevelUpShowcase(
          newLevel: _currentLevel,
          goldReward: 50 + (_currentLevel * 30),
          xpReward: 20 + (_currentLevel * 10),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ui_general_colony_frontier'.tr),
        actions: [
          // 날씨 표시
          _WeatherIndicator(weatherSystem: _weatherSystem),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.military_tech),
            tooltip: 'BattlePass',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BattlePassScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Gacha',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GachaScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shield),
            tooltip: 'Guild War',
            onPressed: () => Navigator.of(context).pushNamed('/guild-war'),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Tournament',
            onPressed: () => Navigator.of(context).pushNamed('/tournament'),
          ),
          IconButton(
            icon: const Icon(Icons.celebration),
            tooltip: 'Seasonal Event',
            onPressed: () => Navigator.of(context).pushNamed('/seasonal-event'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: _ConstructionEffectOverlay(
        effects: _completionEffects,
        child: CrisisOverlay(
          isCrisis: gameState.isCrisis,
          child: Stack(
            children: [
              // 배경
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bg_space.png',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              // 콜로니 라이프 오버레이 (콜로니스트 시각화)
              ColonyLifeOverlay(
                population: gameState.population,
                buildingCount: gameState.buildings.length,
                child: SafeArea(
                  child: Column(
                    children: [
                      const ResourceView(),
                      // 의미 있는 선택 알림
                      if (_choiceSystem.activeChoices.isNotEmpty)
                        _ChoiceBanner(
                          choiceSystem: _choiceSystem,
                          gameState: gameState,
                        ),
                      Expanded(child: _ColonyGrid()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBuildMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBuildMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _BuildMenu(onBuildingBuilt: (name) {
        _showConstructionEffect(name);
      }),
    );
  }

  void _showConstructionEffect(String buildingName) {
    setState(() {
      _completionEffects.add(
        ConstructionCompletionEffectData(
          buildingName: buildingName,
          position: const Offset(200, 300),
          timestamp: DateTime.now(),
        ),
      );
    });

    // 2초 후 제거
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _completionEffects.clear();
        });
      }
    });
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings_settings_coming_soon'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final state = context.read<GameState>();
                final messenger = ScaffoldMessenger.of(context);
                final manager = PersistenceManager();
                await manager.saveGame(state);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('ui_general_game_saved'.tr)),
                  );
                }
              },
              child: Text('ui_general_save_game'.tr),
            ),
            const SizedBox(height: MGSpacing.xsMd),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final state = context.read<GameState>();
                final messenger = ScaffoldMessenger.of(context);
                final manager = PersistenceManager();
                final success = await manager.loadGame(state);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Game Loaded!' : 'No Save Found'),
                    ),
                  );
                }
              },
              child: Text('ui_general_load_game'.tr),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ColonyGrid extends StatelessWidget {
  const _ColonyGrid();

  @override
  Widget build(BuildContext context) {
    final buildings = context.watch<GameState>().buildings;

    if (buildings.isEmpty) {
      return const Center(
        child: Text(
          'No buildings yet.\nStart by building a Solar Panel!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(MGSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: buildings.length,
      itemBuilder: (context, index) {
        final building = buildings[index];
        final synergy = SynergySystem.calculateSynergy(building, buildings);

        return Card(
          color: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: synergy.totalBonus > 1.0
                  ? Colors.amber
                  : Colors.blueAccent,
              width: synergy.totalBonus > 1.0 ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBuildingSprite(building.type, building.id),
                  const SizedBox(height: MGSpacing.xxs),
                  Text(
                    building.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: MGColors.textHighEmphasis,
                    ),
                  ),
                  // 시너지 보너스 표시
                  if (synergy.totalBonus > 1.0)
                    Text(
                      '+${((synergy.totalBonus - 1) * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              // 작업 표시
              if (building.production.isNotEmpty)
                Positioned.fill(
                  child: BuildingWorkIndicator(
                    buildingType: building.type,
                    isProducing: true,
                    productionRate: 1.0,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBuildingSprite(String type, String id) {
    int frameIndex = 0;

    if (type == 'Energy' && id.contains('solar')) {
      frameIndex = 0;
    } else if (type == 'Energy' && id.contains('nuclear')) {
      frameIndex = 0;
    } else if (type == 'Water') {
      frameIndex = 1;
    } else if (type == 'Research') {
      frameIndex = 2;
    } else if (type == 'Storage') {
      frameIndex = 3;
    } else if (type == 'Food') {
      frameIndex = 1;
    }

    return SpriteClipper(
      assetPath: 'assets/images/buildings.png',
      hFrames: 2,
      vFrames: 2,
      frameIndex: frameIndex,
      size: 48,
    );
  }
}

class _BuildMenu extends StatelessWidget {
  final Function(String) onBuildingBuilt;

  const _BuildMenu({required this.onBuildingBuilt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Construction',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: MGSpacing.md),
          ListTile(
            leading: const Icon(Icons.flash_on, color: Colors.yellow),
            title: Text('ui_general_solar_panel'.tr),
            subtitle: Text('ui_general_produces_1_energys'.tr),
            trailing: Text('ui_general_free_proto'.tr),
            onTap: () {
              FlameAudio.play('sfx_build.wav');
              const building = Building(
                id: 'solar',
                name: 'Solar Panel',
                type: 'Energy',
                production: {'energy': 1.0},
              );

              context.read<GameState>().addBuilding(building);

              // 완료 효과 표시
              onBuildingBuilt('Solar Panel');

              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.water_drop, color: MGColors.info),
            title: Text('ui_general_water_extractor'.tr),
            subtitle: Text('ui_general_consumes_1_energy_produces_1'.tr),
            trailing: Text('ui_general_free_proto'.tr),
            onTap: () {
              FlameAudio.play('sfx_build.wav');
              context.read<GameState>().addBuilding(
                const Building(
                  id: 'water',
                  name: 'Water Extractor',
                  type: 'Water',
                  consumption: {'energy': 1.0},
                  production: {'water': 1.0},
                ),
              );
              onBuildingBuilt('Water Extractor');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse, color: MGColors.common),
            title: Text('ui_general_small_warehouse'.tr),
            subtitle: Text('ui_general_100_to_all_storage'.tr),
            trailing: Text('ui_general_free_proto'.tr),
            onTap: () {
              FlameAudio.play('sfx_build.wav');
              context.read<GameState>().addBuilding(
                const Building(
                  id: 'warehouse_s',
                  name: 'Small Warehouse',
                  type: 'Storage',
                  storageIncrease: {
                    'iron': 100,
                    'water': 100,
                    'oxygen': 100,
                    'energy': 100,
                    'food': 100,
                  },
                ),
              );
              onBuildingBuilt('Small Warehouse');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.science, color: Colors.purple),
            title: Text('ui_general_research_lab_3'.tr),
            subtitle: Text('ui_general_produces_1_researchs'.tr),
            trailing: Text('ui_general_free_proto'.tr),
            onTap: () {
              FlameAudio.play('sfx_build.wav');
              context.read<GameState>().addBuilding(
                const Building(
                  id: 'lab',
                  name: 'Research Lab',
                  type: 'Research',
                  production: {'research': 1.0},
                ),
              );
              onBuildingBuilt('Research Lab');
              Navigator.pop(context);
            },
          ),
          if (context.read<GameState>().unlockedTechs.contains('tech_adv_power'))
            ListTile(
              leading: const Icon(Icons.flash_on, color: MGColors.warning),
              title: Text('ui_general_nuclear_reactor'.tr),
              subtitle: Text('ui_general_produces_50_energys'.tr),
              trailing: const Text('Tech'),
              onTap: () {
                context.read<GameState>().addBuilding(
                  const Building(
                    id: 'nuclear',
                    name: 'Nuclear Reactor',
                    type: 'Energy',
                    production: {'energy': 50.0},
                  ),
                );
                onBuildingBuilt('Nuclear Reactor');
                Navigator.pop(context);
              },
            ),
          if (context.read<GameState>().unlockedTechs.contains('tech_hydro'))
            ListTile(
              leading: const Icon(Icons.local_florist, color: Colors.greenAccent),
              title: Text('ui_general_hydroponics_farm'.tr),
              subtitle: Text('ui_general_produces_1_foods'.tr),
              trailing: const Text('Tech'),
              onTap: () {
                context.read<GameState>().addBuilding(
                  const Building(
                    id: 'farm',
                    name: 'Hydroponics Farm',
                    type: 'Food',
                    consumption: {'water': 1.0, 'energy': 1.0},
                    production: {'food': 1.0},
                  ),
                );
                onBuildingBuilt('Hydroponics Farm');
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

/// 건설 완료 효과 데이터
class ConstructionCompletionEffectData {
  final String buildingName;
  final Offset position;
  final DateTime timestamp;

  ConstructionCompletionEffectData({
    required this.buildingName,
    required this.position,
    required this.timestamp,
  });
}

/// 간단한 건설 완료 효과 오버레이
class _ConstructionEffectOverlay extends StatefulWidget {
  final Widget child;
  final List<ConstructionCompletionEffectData> effects;

  const _ConstructionEffectOverlay({
    required this.child,
    required this.effects,
  });

  @override
  State<_ConstructionEffectOverlay> createState() =>
      _ConstructionEffectOverlayState();
}

class _ConstructionEffectOverlayState extends State<_ConstructionEffectOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ...widget.effects.map((effect) => _buildEffect(effect)),
      ],
    );
  }

  Widget _buildEffect(ConstructionCompletionEffectData effect) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final opacity = progress < 0.8 ? progress / 0.8 : 1 - ((progress - 0.8) / 0.2);
        final scale = progress < 0.3 ? progress / 0.3 : 1.0;

        return Positioned(
          left: effect.position.dx - 60,
          top: effect.position.dy - 60,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      'COMPLETE!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      effect.buildingName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeatherIndicator extends StatelessWidget {
  final WeatherSystem weatherSystem;

  const _WeatherIndicator({required this.weatherSystem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getWeatherIcon(), size: 16, color: _getWeatherColor()),
          const SizedBox(width: 4),
          Text(
            _getWeatherName(),
            style: TextStyle(
              color: _getWeatherColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    switch (weatherSystem.currentWeather) {
      case WeatherType.clear:
        return Icons.wb_sunny;
      case WeatherType.solarFlare:
        return Icons.flare;
      case WeatherType.dustStorm:
        return Icons.air;
      case WeatherType.meteorShower:
        return Icons.star;
      case WeatherType.cosmicStorm:
        return Icons.thunderstorm;
    }
  }

  Color _getWeatherColor() {
    switch (weatherSystem.currentWeather) {
      case WeatherType.clear:
        return Colors.yellow;
      case WeatherType.solarFlare:
        return Colors.orange;
      case WeatherType.dustStorm:
        return Colors.brown;
      case WeatherType.meteorShower:
        return Colors.purple;
      case WeatherType.cosmicStorm:
        return Colors.red;
    }
  }

  String _getWeatherName() {
    switch (weatherSystem.currentWeather) {
      case WeatherType.clear:
        return 'Clear';
      case WeatherType.solarFlare:
        return 'Solar Flare';
      case WeatherType.dustStorm:
        return 'Dust Storm';
      case WeatherType.meteorShower:
        return 'Meteor Shower';
      case WeatherType.cosmicStorm:
        return 'Cosmic Storm';
    }
  }
}

class _ChoiceBanner extends StatelessWidget {
  final MeaningfulChoiceSystem choiceSystem;
  final GameState gameState;

  const _ChoiceBanner({
    required this.choiceSystem,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final choice = choiceSystem.activeChoices.firstOrNull;
    if (choice == null || choice.isExpired) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                choice.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${choice.duration.inSeconds}s',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            choice.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: choice.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return ElevatedButton(
                onPressed: () => _makeChoice(context, choice.id, index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Text(option.title),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _makeChoice(BuildContext context, String choiceId, int optionIndex) {
    final result = choiceSystem.makeChoice(choiceId, optionIndex);
    gameState.applyEventEffect(result);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Choice made: ${result.entries.map((e) => '${e.key}:${e.value}').join(', ')}'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }
}
