import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_state.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';


class ResourceView extends StatelessWidget {
  const ResourceView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ResourceItem(
            icon: Icons.grid_on,
            value: state.iron,
            max: state.getMax('iron'),
            label: 'ui_general_iron_hold_lobby'.tr,
            color: MGColors.common,
          ),
          _ResourceItem(
            icon: Icons.water_drop,
            value: state.water,
            max: state.getMax('water'),
            label: 'ui_general_water_extractor'.tr,
            color: MGColors.info,
          ),
          _ResourceItem(
            icon: Icons.air,
            value: state.oxygen,
            max: state.getMax('oxygen'),
            label: 'O2',
            color: Colors.cyan,
          ),
          _ResourceItem(
            icon: Icons.flash_on,
            value: state.energy,
            max: state.getMax('energy'),
            label: 'ui_general_cp_agentcurrentcombatpower'.tr,
            color: Colors.yellow,
          ),
          _ResourceItem(
            icon: Icons.restaurant,
            value: state.food,
            max: state.getMax('food'),
            label: 'ui_general_produces_1_foods'.tr,
            color: MGColors.success,
          ),
        ],
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final IconData icon;
  final double value;
  final double max;
  final String label;
  final Color color;

  const _ResourceItem({
    required this.icon,
    required this.value,
    required this.max,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: MGSpacing.xxs),
        Text(
          '${value.toStringAsFixed(0)} / ${max.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
