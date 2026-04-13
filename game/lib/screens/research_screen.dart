import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_state.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';import 'package:mg_common_game/l10n/localization.dart';


class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('ui_general_research_lab_3'.tr),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Research: ${state.research.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(MGSpacing.md),
        children: [
          _TechCard(
            id: 'tech_adv_power',
            name: 'Advanced Power',
            description: 'Unlocks Nuclear Reactor.',
            cost: 50,
            isUnlocked: state.unlockedTechs.contains('tech_adv_power'),
            onUnlock: () => state.unlockTech('tech_adv_power'),
          ),
          _TechCard(
            id: 'tech_hydro',
            name: 'Hydroponics',
            description: 'Unlocks Hydroponics Farm.',
            cost: 30,
            isUnlocked: state.unlockedTechs.contains('tech_hydro'),
            onUnlock: () => state.unlockTech('tech_hydro'),
          ),
        ],
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final double cost;
  final bool isUnlocked;
  final VoidCallback onUnlock;

  const _TechCard({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.isUnlocked,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnlocked ? MGColors.success.withValues(alpha: 0.2) : Colors.grey[850],
      child: ListTile(
        title: Text(name),
        subtitle: Text(description),
        trailing: isUnlocked
            ? const Icon(Icons.check, color: MGColors.success)
            : ElevatedButton(
                onPressed: onUnlock,
                child: Text('notification_unlock_costtostringasfixed0'.tr),
              ),
      ),
    );
  }
}
