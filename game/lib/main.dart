import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'package:game/core/game_state.dart';
import 'package:game/core/population_manager.dart';
import 'package:game/core/building_manager.dart';
import 'package:game/screens/colony_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
// Colony Frontier — MG-0023
// Genre: Colony · Idle · Survival · Simulation · Strategy
// ═══════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection & data setup
  _registerManagers();
  _registerColonyUpgrades();
  _registerBuildingTemplates();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        ChangeNotifierProvider.value(
          value: GetIt.I<UpgradeManager>(),
        ),
        ChangeNotifierProvider.value(
          value: GetIt.I<PopulationManager>(),
        ),
      ],
      child: const ColonyApp(),
    ),
  );
}

// ─── Manager Registration ──────────────────────────────────────────────
void _registerManagers() {
  final getIt = GetIt.I;

  getIt.registerSingleton<UpgradeManager>(UpgradeManager());
  getIt.registerSingleton<PopulationManager>(PopulationManager());
  getIt.registerSingleton<BuildingManager>(BuildingManager());
}

// ─── Colony Upgrade Definitions (8 upgrades) ───────────────────────────
/// Upgrades are purchased with Research points.
/// Each upgrade boosts a specific aspect of colony production or efficiency.
void _registerColonyUpgrades() {
  final um = GetIt.I<UpgradeManager>();

  // 1. Mining — iron production
  um.registerUpgrade(Upgrade(
    id: 'mining_drill',
    name: 'Mining Drill',
    description: 'Advanced drills increase iron output per building',
    maxLevel: 10,
    baseCost: 30,
    costMultiplier: 1.4,
    valuePerLevel: 0.15,
  ));

  // 2. Water — extraction rate
  um.registerUpgrade(Upgrade(
    id: 'water_purifier',
    name: 'Water Purifier',
    description: 'High-efficiency filters boost water extraction rate',
    maxLevel: 10,
    baseCost: 30,
    costMultiplier: 1.4,
    valuePerLevel: 0.15,
  ));

  // 3. Energy — solar output
  um.registerUpgrade(Upgrade(
    id: 'solar_array',
    name: 'Solar Array',
    description: 'Expanded solar collectors generate more energy',
    maxLevel: 10,
    baseCost: 25,
    costMultiplier: 1.35,
    valuePerLevel: 0.20,
  ));

  // 4. Food — crop yield
  um.registerUpgrade(Upgrade(
    id: 'crop_genetics',
    name: 'Crop Genetics',
    description: 'Bio-engineered seeds improve hydroponic food yield',
    maxLevel: 10,
    baseCost: 40,
    costMultiplier: 1.45,
    valuePerLevel: 0.15,
  ));

  // 5. Oxygen — reduced colonist O2 consumption
  um.registerUpgrade(Upgrade(
    id: 'air_recycler',
    name: 'Air Recycler',
    description: 'Recirculation system reduces oxygen consumption',
    maxLevel: 8,
    baseCost: 50,
    costMultiplier: 1.5,
    valuePerLevel: 0.10,
  ));

  // 6. Storage — all resource caps
  um.registerUpgrade(Upgrade(
    id: 'cargo_bay',
    name: 'Cargo Bay',
    description: 'Expanded modules increase all resource storage capacity',
    maxLevel: 10,
    baseCost: 35,
    costMultiplier: 1.4,
    valuePerLevel: 0.25,
  ));

  // 7. Research — output speed
  um.registerUpgrade(Upgrade(
    id: 'lab_equipment',
    name: 'Lab Equipment',
    description: 'Advanced instruments accelerate research output',
    maxLevel: 10,
    baseCost: 45,
    costMultiplier: 1.5,
    valuePerLevel: 0.20,
  ));

  // 8. Construction — build cost reduction
  um.registerUpgrade(Upgrade(
    id: 'prefab_modules',
    name: 'Prefab Modules',
    description: 'Pre-fabricated parts reduce building construction costs',
    maxLevel: 8,
    baseCost: 60,
    costMultiplier: 1.6,
    valuePerLevel: 0.08,
  ));
}

// ─── Building Template Definitions (8 templates) ───────────────────────
/// Templates define one-time construction cost, ongoing production,
/// ongoing consumption, storage bonuses, and housing capacity.
void _registerBuildingTemplates() {
  final bm = GetIt.I<BuildingManager>();

  bm.registerTemplate(const BuildingTemplate(
    id: 'solar_panel',
    name: 'Solar Panel',
    type: 'Energy',
    cost: {'iron': 10},
    production: {'energy': 1.0},
  ));

  bm.registerTemplate(const BuildingTemplate(
    id: 'water_extractor',
    name: 'Water Extractor',
    type: 'Water',
    cost: {'iron': 15},
    consumption: {'energy': 1.0},
    production: {'water': 1.0},
  ));

  bm.registerTemplate(const BuildingTemplate(
    id: 'oxygen_generator',
    name: 'O2 Generator',
    type: 'Oxygen',
    cost: {'iron': 20},
    consumption: {'energy': 1.0, 'water': 0.5},
    production: {'oxygen': 1.5},
  ));

  bm.registerTemplate(const BuildingTemplate(
    id: 'hydroponic_farm',
    name: 'Hydroponic Farm',
    type: 'Food',
    cost: {'iron': 25},
    consumption: {'water': 1.0, 'energy': 1.0},
    production: {'food': 1.0},
    requiredTech: 'tech_hydro',
  ));

  bm.registerTemplate(const BuildingTemplate(
    id: 'research_lab',
    name: 'Research Lab',
    type: 'Research',
    cost: {'iron': 30},
    consumption: {'energy': 2.0},
    production: {'research': 1.0},
  ));

  bm.registerTemplate(const BuildingTemplate(
    id: 'warehouse',
    name: 'Warehouse',
    type: 'Storage',
    cost: {'iron': 20},
    storageIncrease: {
      'iron': 100,
      'water': 100,
      'oxygen': 100,
      'energy': 100,
      'food': 100,
    },
  ));

  bm.registerTemplate(const BuildingTemplate(
    id: 'habitat',
    name: 'Habitat Module',
    type: 'Housing',
    cost: {'iron': 40},
    consumption: {'energy': 2.0},
    housingCapacity: 10,
  ));

  bm.registerTemplate(const BuildingTemplate(
    id: 'nuclear_reactor',
    name: 'Nuclear Reactor',
    type: 'Energy',
    cost: {'iron': 100},
    production: {'energy': 50.0},
    requiredTech: 'tech_adv_power',
  ));
}

// ─── App Widget ────────────────────────────────────────────────────────
class ColonyApp extends StatelessWidget {
  const ColonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colony Frontier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          color: Color(0xFF1E293B),
          elevation: 2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3B82F6),
          foregroundColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF334155),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const ColonyScreen(),
    );
  }
}
