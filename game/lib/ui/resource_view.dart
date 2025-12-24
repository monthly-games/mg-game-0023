import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_state.dart';

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
            label: 'Iron',
            color: Colors.grey,
          ),
          _ResourceItem(
            icon: Icons.water_drop,
            value: state.water,
            max: state.getMax('water'),
            label: 'Water',
            color: Colors.blue,
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
            label: 'Power',
            color: Colors.yellow,
          ),
          _ResourceItem(
            icon: Icons.restaurant,
            value: state.food,
            max: state.getMax('food'),
            label: 'Food',
            color: Colors.green,
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
        const SizedBox(height: 4),
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
