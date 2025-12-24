import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_icon_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_linear_progress.dart';

/// MG-0023 Colony Frontier HUD
/// 우주 식민지 시뮬레이션 게임용 HUD - 자원, 인구, 연구 포인트 표시
class MGColonyHud extends StatelessWidget {
  final double energy;
  final double maxEnergy;
  final double water;
  final double maxWater;
  final double oxygen;
  final double maxOxygen;
  final double food;
  final double maxFood;
  final double iron;
  final double maxIron;
  final double research;
  final int population;
  final bool isCrisis;
  final VoidCallback? onPause;
  final VoidCallback? onBuild;
  final VoidCallback? onResearch;

  const MGColonyHud({
    super.key,
    required this.energy,
    required this.maxEnergy,
    required this.water,
    required this.maxWater,
    required this.oxygen,
    required this.maxOxygen,
    required this.food,
    required this.maxFood,
    required this.iron,
    required this.maxIron,
    required this.research,
    required this.population,
    this.isCrisis = false,
    this.onPause,
    this.onBuild,
    this.onResearch,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 위기 경고
          if (isCrisis) _buildCrisisAlert(),
          Padding(
            padding: EdgeInsets.all(MGSpacing.sm),
            child: Column(
              children: [
                // 상단 HUD: 자원 바
                _buildResourcePanel(),
                SizedBox(height: MGSpacing.xs),
                // 하단 정보: 인구, 연구, 버튼
                Row(
                  children: [
                    _buildPopulationInfo(),
                    SizedBox(width: MGSpacing.sm),
                    _buildResearchInfo(),
                    const Spacer(),
                    _buildActionButtons(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisAlert() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber, color: Colors.white, size: 18),
          SizedBox(width: MGSpacing.xs),
          Text(
            'CRITICAL: VITAL RESOURCES DEPLETED!',
            style: MGTextStyles.buttonSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcePanel() {
    return Container(
      padding: EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1행: Energy, Water
          Row(
            children: [
              Expanded(
                child: _buildResourceBar(
                  icon: Icons.bolt,
                  label: 'Energy',
                  value: energy,
                  maxValue: maxEnergy,
                  color: Colors.yellow,
                ),
              ),
              SizedBox(width: MGSpacing.sm),
              Expanded(
                child: _buildResourceBar(
                  icon: Icons.water_drop,
                  label: 'Water',
                  value: water,
                  maxValue: maxWater,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.xs),
          // 2행: Oxygen, Food
          Row(
            children: [
              Expanded(
                child: _buildResourceBar(
                  icon: Icons.air,
                  label: 'O2',
                  value: oxygen,
                  maxValue: maxOxygen,
                  color: Colors.cyan,
                ),
              ),
              SizedBox(width: MGSpacing.sm),
              Expanded(
                child: _buildResourceBar(
                  icon: Icons.restaurant,
                  label: 'Food',
                  value: food,
                  maxValue: maxFood,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.xs),
          // 3행: Iron
          _buildResourceBar(
            icon: Icons.construction,
            label: 'Iron',
            value: iron,
            maxValue: maxIron,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildResourceBar({
    required IconData icon,
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final double ratio = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0;
    final bool isLow = ratio < 0.2;

    return Row(
      children: [
        Icon(icon, color: isLow ? Colors.red : color, size: 16),
        SizedBox(width: MGSpacing.xxs),
        Expanded(
          child: MGLinearProgress(
            value: ratio,
            height: 8,
            backgroundColor: color.withOpacity(0.2),
            progressColor: isLow ? Colors.red : color,
          ),
        ),
        SizedBox(width: MGSpacing.xxs),
        Text(
          '${value.toInt()}',
          style: MGTextStyles.caption.copyWith(
            color: isLow ? Colors.red : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPopulationInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MGSpacing.sm,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(MGSpacing.xs),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, color: Colors.blue, size: 16),
          SizedBox(width: MGSpacing.xs),
          Text(
            '$population',
            style: MGTextStyles.buttonSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MGSpacing.sm,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(MGSpacing.xs),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science, color: Colors.purple, size: 16),
          SizedBox(width: MGSpacing.xs),
          Text(
            '${research.toInt()}',
            style: MGTextStyles.buttonSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onBuild != null)
          MGIconButton(
            icon: Icons.add_box,
            onPressed: onBuild!,
            size: MGIconButtonSize.small,
          ),
        if (onResearch != null)
          MGIconButton(
            icon: Icons.science,
            onPressed: onResearch!,
            size: MGIconButtonSize.small,
          ),
        if (onPause != null)
          MGIconButton(
            icon: Icons.settings,
            onPressed: onPause!,
            size: MGIconButtonSize.small,
          ),
      ],
    );
  }
}
