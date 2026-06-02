import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_progress.dart';


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
  final VoidCallback? onDailyHub;
  final VoidCallback? onGuildWar;
  final VoidCallback? onTournament;
  final VoidCallback? onSeasonalEvent;

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
    this.onDailyHub,
    this.onGuildWar,
    this.onTournament,
    this.onSeasonalEvent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 위기 경고
          if (isCrisis) _buildCrisisAlert(),
          Padding(
            padding: const EdgeInsets.all(MGSpacing.sm),
            child: Column(
              children: [
                // 상단 HUD: 자원 바
                _buildResourcePanel(),
                const SizedBox(height: MGSpacing.xs),
                // 하단 정보: 인구, 연구, 버튼
                Row(
                  children: [
                    _buildPopulationInfo(),
                    const SizedBox(width: MGSpacing.sm),
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
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.error.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: MGColors.error.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber, color: MGColors.textHighEmphasis, size: 18),
          const SizedBox(width: MGSpacing.xs),
          Text(
            'CRITICAL: VITAL RESOURCES DEPLETED!',
            style: MGTextStyles.buttonSmall.copyWith(
              color: MGColors.textHighEmphasis,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcePanel() {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withValues(alpha: 0.85),
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
                  label: 'ui_general_playerenergy'.tr,
                  value: energy,
                  maxValue: maxEnergy,
                  color: Colors.yellow,
                ),
              ),
              const SizedBox(width: MGSpacing.sm),
              Expanded(
                child: _buildResourceBar(
                  icon: Icons.water_drop,
                  label: 'ui_general_water_extractor'.tr,
                  value: water,
                  maxValue: maxWater,
                  color: MGColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: MGSpacing.xs),
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
              const SizedBox(width: MGSpacing.sm),
              Expanded(
                child: _buildResourceBar(
                  icon: Icons.restaurant,
                  label: 'ui_general_produces_1_foods'.tr,
                  value: food,
                  maxValue: maxFood,
                  color: MGColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: MGSpacing.xs),
          // 3행: Iron
          _buildResourceBar(
            icon: Icons.construction,
            label: 'ui_general_iron_hold_lobby'.tr,
            value: iron,
            maxValue: maxIron,
            color: MGColors.common,
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
        Icon(icon, color: isLow ? MGColors.error : color, size: 16),
        const SizedBox(width: MGSpacing.xxs),
        Expanded(
          child: MGLinearProgress(
            value: ratio,
            height: 8,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: isLow ? MGColors.error : color,
          ),
        ),
        const SizedBox(width: MGSpacing.xxs),
        Text(
          '${value.toInt()}',
          style: MGTextStyles.caption.copyWith(
            color: isLow ? MGColors.error : MGColors.textHighEmphasis,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPopulationInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.sm,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.info.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(MGSpacing.xs),
        border: Border.all(color: MGColors.info.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people, color: MGColors.info, size: 16),
          const SizedBox(width: MGSpacing.xs),
          Text(
            '$population',
            style: MGTextStyles.buttonSmall.copyWith(
              color: MGColors.textHighEmphasis,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.sm,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(MGSpacing.xs),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.science, color: Colors.purple, size: 16),
          const SizedBox(width: MGSpacing.xs),
          Text(
            '${research.toInt()}',
            style: MGTextStyles.buttonSmall.copyWith(
              color: MGColors.textHighEmphasis,
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
            buttonSize: MGIconButtonSize.small,
          ),
        if (onResearch != null)
          MGIconButton(
            icon: Icons.science,
            onPressed: onResearch!,
            buttonSize: MGIconButtonSize.small,
          ),
                if (onGuildWar != null)
                  MGIconButton(
                    icon: Icons.shield,
                    onPressed: onGuildWar!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onTournament != null)
                  MGIconButton(
                    icon: Icons.emoji_events,
                    onPressed: onTournament!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onSeasonalEvent != null)
                  MGIconButton(
                    icon: Icons.celebration,
                    onPressed: onSeasonalEvent!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onDailyHub != null)
                  MGIconButton(
                    icon: Icons.calendar_today,
                    onPressed: onDailyHub!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
        if (onPause != null)
          MGIconButton(
            icon: Icons.settings,
            onPressed: onPause!,
            buttonSize: MGIconButtonSize.small,
          ),
      ],
    );
  }


  // ignore: unused_element
  Widget _buildSpineCharacter() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withAlpha(150), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 24, color: Colors.white),
            SizedBox(height: 2),
            Text(
              'Chef',
              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

}
