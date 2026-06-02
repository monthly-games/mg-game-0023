// ignore_for_file: depend_on_referenced_packages
// ============================================================
// Achievement Screen -- MG-0023 Colony Frontier
// Genre: Crossgame / Raid / Event · Retention System UI
//
// Template: Based on MG-0024 canonical template.
// ============================================================

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';

/// Achievement category for UI grouping.
enum AchievementCategory {
  combat('Combat', Icons.sports_martial_arts_rounded),
  progression('Progression', Icons.trending_up_rounded),
  collection('Collection', Icons.collections_bookmark_rounded),
  social('Social', Icons.people_rounded),
  special('Special', Icons.star_rounded);

  final String label;
  final IconData icon;
  const AchievementCategory(this.label, this.icon);
}

/// Achievement screen for MG-0023 Colony Frontier.
///
/// Displays achievements grouped by category with unlock states,
/// point values, and completion percentages.
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late final AchievementManager _achievementManager;
  late final TabController _tabController;

  static const int _defaultPoints = 10;

  @override
  void initState() {
    super.initState();
    _achievementManager = GetIt.I<AchievementManager>();
    _achievementManager.addListener(_onUpdate);
    _tabController = TabController(
      length: AchievementCategory.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _achievementManager.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  AchievementCategory _getCategory(Achievement achievement) {
    final id = achievement.id.toLowerCase();
    if (id.contains('battle') || id.contains('combat') || id.contains('kill') || id.contains('win')) {
      return AchievementCategory.combat;
    } else if (id.contains('collect') || id.contains('unlock') || id.contains('discover')) {
      return AchievementCategory.collection;
    } else if (id.contains('friend') || id.contains('guild') || id.contains('social') || id.contains('coop')) {
      return AchievementCategory.social;
    } else if (id.contains('level') || id.contains('upgrade') || id.contains('stage') || id.contains('progress')) {
      return AchievementCategory.progression;
    }
    return AchievementCategory.special;
  }

  List<Achievement> _achievementsFor(AchievementCategory cat) {
    return _achievementManager.allAchievements
        .where((a) => _getCategory(a) == cat)
        .toList();
  }

  int _totalPoints() {
    return _achievementManager.unlockedAchievements.length * _defaultPoints;
  }

  int _maxPoints() {
    return _achievementManager.allAchievements.length * _defaultPoints;
  }

  @override
  Widget build(BuildContext context) {
    final totalPts = _totalPoints();
    final maxPts = _maxPoints();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: MGTextStyles.h2.copyWith(
            color: MGColors.textHighEmphasis,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: MGSpacing.horizontal(MGSpacing.md),
            child: Center(
              child: Container(
                padding: MGSpacing.symmetric(
                  horizontal: MGSpacing.sm,
                  vertical: MGSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: MGColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(MGSpacing.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: MGIcons.badgeSize,
                      color: MGColors.gold,
                    ),
                    MGSpacing.hXxs,
                    Text(
                      '$totalPts / $maxPts',
                      style: MGTextStyles.hudSmall.copyWith(
                        color: MGColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: MGColors.gold,
          labelColor: MGColors.gold,
          unselectedLabelColor: MGColors.textMediumEmphasis,
          tabs: AchievementCategory.values.map((cat) {
            final list = _achievementsFor(cat);
            final unlocked = list.where((a) => a.unlocked).length;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: MGIcons.badgeSize),
                  MGSpacing.hXxs,
                  Text(cat.label),
                  if (list.isNotEmpty) ...[
                    MGSpacing.hXxs,
                    Text(
                      '($unlocked/${list.length})',
                      style: MGTextStyles.caption,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: AchievementCategory.values
            .map(_buildCategoryTab)
            .toList(),
      ),
    );
  }

  Widget _buildCategoryTab(AchievementCategory category) {
    final achievements = _achievementsFor(category);

    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: MGSpacing.xxl,
              color: MGColors.textDisabled,
            ),
            MGSpacing.vMd,
            Text(
              'No ${category.label} achievements yet',
              style: MGTextStyles.body.copyWith(
                color: MGColors.textDisabled,
              ),
            ),
          ],
        ),
      );
    }

    final unlockedCount = achievements.where((a) => a.unlocked).length;
    final pct = (unlockedCount / achievements.length * 100).round();

    return Padding(
      padding: MGSpacing.horizontal(MGSpacing.md),
      child: Column(
        children: [
          MGSpacing.vMd,
          _buildCategoryHeader(category, unlockedCount, achievements.length, pct),
          MGSpacing.vSm,
          Expanded(
            child: ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < achievements.length - 1 ? MGSpacing.xs : 0,
                  ),
                  child: _buildAchievementTile(achievements[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    AchievementCategory category,
    int unlockedCount,
    int totalCount,
    int pct,
  ) {
    return MGCard(
      backgroundColor: MGColors.surfaceDark,
      borderColor: MGColors.border,
      borderWidth: 1,
      padding: MGSpacing.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            category.icon,
            size: MGIcons.navigationSize,
            color: MGColors.gold,
          ),
          MGSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlockedCount / $totalCount unlocked',
                  style: MGTextStyles.bodySmall.copyWith(
                    color: MGColors.textHighEmphasis,
                  ),
                ),
                MGSpacing.vXxs,
                MGLinearProgress(
                  value: totalCount > 0 ? unlockedCount / totalCount : 0,
                  valueColor: MGColors.gold,
                  height: 4,
                  borderRadius: 2,
                ),
              ],
            ),
          ),
          MGSpacing.hSm,
          Text(
            '$pct%',
            style: MGTextStyles.hud.copyWith(
              color: MGColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement achievement) {
    final isUnlocked = achievement.unlocked;

    return MGCard(
      backgroundColor: isUnlocked ? MGColors.cardDark : MGColors.surfaceDark,
      borderColor: isUnlocked
          ? MGColors.success.withValues(alpha: 0.4)
          : MGColors.border,
      borderWidth: 1,
      child: Row(
        children: [
          Container(
            width: MGSpacing.xxl,
            height: MGSpacing.xxl,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? MGColors.gold.withValues(alpha: 0.2)
                  : MGColors.common.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MGSpacing.sm),
            ),
            child: Icon(
              isUnlocked
                  ? Icons.emoji_events_rounded
                  : Icons.lock_rounded,
              color: isUnlocked ? MGColors.gold : MGColors.common,
              size: MGIcons.navigationSize,
            ),
          ),
          MGSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: MGTextStyles.body.copyWith(
                    color: isUnlocked
                        ? MGColors.textHighEmphasis
                        : MGColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  achievement.hidden && !isUnlocked
                      ? '???'
                      : achievement.description,
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.textMediumEmphasis,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: MGSpacing.symmetric(
                  horizontal: MGSpacing.xs,
                  vertical: MGSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? MGColors.gold.withValues(alpha: 0.2)
                      : MGColors.common.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MGSpacing.xxs),
                ),
                child: Text(
                  '$_defaultPoints pts',
                  style: MGTextStyles.caption.copyWith(
                    color: isUnlocked ? MGColors.gold : MGColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isUnlocked) ...[
                MGSpacing.vXxs,
                const Icon(
                  Icons.check_circle_rounded,
                  size: MGIcons.badgeSize,
                  color: MGColors.success,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
