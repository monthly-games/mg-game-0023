import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';
import '../core/game_state.dart';
import '../core/persistence_manager.dart';
import '../models/building_model.dart';
import '../ui/resource_view.dart';
import '../ui/sprite_clipper.dart';
import 'research_screen.dart';

class ColonyScreen extends StatefulWidget {
  const ColonyScreen({super.key});

  @override
  State<ColonyScreen> createState() => _ColonyScreenState();
}

class _ColonyScreenState extends State<ColonyScreen> {
  Timer? _gameLoop;

  @override
  void initState() {
    super.initState();
    // Start Game Loop (10 ticks per second for smoothness)
    _gameLoop = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      context.read<GameState>().update(0.1);
    });

    // Play BGM
    FlameAudio.bgm.play('bgm_colony.mp3', volume: 0.3);
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for events to display
    final gameState = context.watch<GameState>();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colony Frontier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResearchScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_space.png',
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const ResourceView(),
                if (context.watch<GameState>().isCrisis)
                  Container(
                    color: Colors.red.withOpacity(0.8),
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'CRITICAL ALERT: VITAL RESOURCES DEPLETED!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(child: _ColonyGrid()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBuildMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBuildMenu(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => _BuildMenu());
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final state = context.read<GameState>();
                final manager = PersistenceManager();
                await manager.saveGame(state);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Game Saved!')));
                }
              },
              child: const Text('Save Game'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final state = context.read<GameState>();
                final manager = PersistenceManager();
                bool success = await manager.loadGame(state);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Game Loaded!' : 'No Save Found'),
                    ),
                  );
                }
              },
              child: const Text('Load Game'),
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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: buildings.length,
      itemBuilder: (context, index) {
        final building = buildings[index];
        return Card(
          color: Colors.black54, // Transparent dark
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.blueAccent, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sprite Logic
              _buildBuildingSprite(building.type, building.id),
              const SizedBox(height: 4),
              Text(
                building.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Energy':
        return Icons.flash_on;
      case 'Water':
        return Icons.water_drop;
      case 'Oxygen':
        return Icons.air;
      case 'Food':
        return Icons
            .local_florist; // Changed from agriculture which might not exist
      case 'Iron':
        return Icons.construction;
      default:
        return Icons.domain;
    }
  }

  Widget _buildBuildingSprite(String type, String id) {
    int frameIndex = 0;

    if (type == 'Energy' && id.contains('solar'))
      frameIndex = 0;
    else if (type == 'Energy' && id.contains('nuclear'))
      frameIndex = 0;
    else if (type == 'Water')
      frameIndex = 1;
    else if (type == 'Research')
      frameIndex = 2;
    else if (type == 'Storage')
      frameIndex = 3;
    else if (type == 'Food')
      frameIndex = 1;

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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Construction',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.flash_on, color: Colors.yellow),
            title: const Text('Solar Panel'),
            subtitle: const Text('Produces 1 Energy/s'),
            trailing: const Text('Free (Proto)'),
            onTap: () {
              FlameAudio.play('sfx_build.wav');
              context.read<GameState>().addBuilding(
                const Building(
                  id: 'solar', // Unique ID logic needed later
                  name: 'Solar Panel',
                  type: 'Energy',
                  production: {'energy': 1.0},
                ),
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.water_drop, color: Colors.blue),
            title: const Text('Water Extractor'),
            subtitle: const Text('Consumes 1 Energy, Produces 1 Water'),
            trailing: const Text('Free (Proto)'),
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
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse, color: Colors.grey),
            title: const Text('Small Warehouse'),
            subtitle: const Text('+100 to All Storage'),
            trailing: const Text('Free (Proto)'),
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
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.science, color: Colors.purple),
            title: const Text('Research Lab'),
            subtitle: const Text('Produces 1 Research/s'),
            trailing: const Text('Free (Proto)'),
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
              Navigator.pop(context);
            },
          ),
          if (context.read<GameState>().unlockedTechs.contains(
            'tech_adv_power',
          ))
            ListTile(
              leading: const Icon(Icons.flash_on, color: Colors.orange),
              title: const Text('Nuclear Reactor'),
              subtitle: const Text('Produces 50 Energy/s'),
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
                Navigator.pop(context);
              },
            ),
          if (context.read<GameState>().unlockedTechs.contains('tech_hydro'))
            ListTile(
              leading: const Icon(
                Icons.local_florist,
                color: Colors.greenAccent,
              ),
              title: const Text('Hydroponics Farm'),
              subtitle: const Text('Produces 1 Food/s'),
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
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
