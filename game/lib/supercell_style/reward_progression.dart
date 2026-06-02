library;

/// 보상 진행 시스템 - Supercell 스타일 레벨업 및 보상 표시
/// 플레이어의 성취를 시각화하고 지속적인 참여 유도

import 'package:flutter/material.dart';
import 'dart:async';

/// 보상 타입
enum RewardType {
  coins,
  gems,
  cards,
  experience,
  special,
}

/// 보상 항목
class RewardItem {
  final RewardType type;
  final int amount;
  final String name;
  final IconData icon;
  final Color color;
  final String? description;

  const RewardItem({
    required this.type,
    required this.amount,
    required this.name,
    required this.icon,
    required this.color,
    this.description,
  });

  /// 샘플 보상 생성
  static List<RewardItem> generateLevelUpRewards(int level) {
    return [
      RewardItem(
        type: RewardType.coins,
        amount: 100 * level,
        name: '골드',
        icon: Icons.monetization_on,
        color: Colors.amber,
        description: '$level레벨 달성 보상',
      ),
      RewardItem(
        type: RewardType.gems,
        amount: 5 + (level ~/ 10),
        name: '젬',
        icon: Icons.diamond,
        color: Colors.cyan,
      ),
      if (level % 5 == 0)
        RewardItem(
          type: RewardType.cards,
          amount: 1,
          name: '레어 카드',
          icon: Icons.style,
          color: Colors.purple,
          description: '5레벨마다 특별 보상',
        ),
      RewardItem(
        type: RewardType.experience,
        amount: 50 * level,
        name: '경험치',
        icon: Icons.stars,
        color: Colors.orange,
      ),
    ];
  }
}

/// 플레이어 진행 상태
class PlayerProgress {
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final int totalTrophies;
  final int winStreak;
  final List<int> unlockedLevels;

  const PlayerProgress({
    this.level = 1,
    this.currentXP = 0,
    this.xpToNextLevel = 100,
    this.totalTrophies = 0,
    this.winStreak = 0,
    this.unlockedLevels = const [1],
  });

  double get xpProgress => currentXP / xpToNextLevel;

  PlayerProgress copyWith({
    int? level,
    int? currentXP,
    int? xpToNextLevel,
    int? totalTrophies,
    int? winStreak,
    List<int>? unlockedLevels,
  }) {
    return PlayerProgress(
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      totalTrophies: totalTrophies ?? this.totalTrophies,
      winStreak: winStreak ?? this.winStreak,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
    );
  }
}

/// 레벨업 쇼케이스 화면
class LevelUpShowcaseScreen extends StatefulWidget {
  final int newLevel;
  final List<RewardItem> rewards;
  final VoidCallback onContinue;

  const LevelUpShowcaseScreen({
    super.key,
    required this.newLevel,
    required this.rewards,
    required this.onContinue,
  });

  @override
  State<LevelUpShowcaseScreen> createState() => _LevelUpShowcaseScreenState();
}

class _LevelUpShowcaseScreenState extends State<LevelUpShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rewardController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rewardAnimation;
  int _displayedRewardIndex = 0;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rewardController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _rewardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rewardController,
        curve: Curves.easeOutBack,
      ),
    );

    _scaleController.forward();

    // 보상 항목 순차 표시
    _showRewardsSequentially();
  }

  void _showRewardsSequentially() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _showNextReward();
      }
    });
  }

  void _showNextReward() {
    if (_displayedRewardIndex < widget.rewards.length) {
      setState(() {
        _displayedRewardIndex++;
      });
      _rewardController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showNextReward();
        }
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rewardController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFF6F00),
              Color(0xFF311B92),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 파티클 효과
              _buildParticles(),

              // 메인 컨텐츠
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // 레벨업 타이틀
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value.clamp(0.0, 1.0),
                          child: Opacity(
                            opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                            child: _buildLevelUpBadge(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // 레벨 텍스트
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value.clamp(0.5, 1.0),
                          child: Opacity(
                            opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                            child: Text(
                              'LEVEL ${widget.newLevel}',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 16,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // 보상 섹션
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                          child: const Text(
                            '보상 획득!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // 보상 목록
                    SizedBox(
                      height: 120,
                      child: _buildRewardsList(),
                    ),

                    const SizedBox(height: 40),

                    // 계속 버튼
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                          child: FilledButton.icon(
                            onPressed: widget.onContinue,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('계속하기'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFF6F00),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelUpBadge() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFF6F00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.6),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
      ),
      child: const Icon(
        Icons.stars,
        size: 64,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRewardsList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: widget.rewards.length,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        final reward = widget.rewards[index];
        final isShown = index < _displayedRewardIndex;

        return AnimatedBuilder(
          animation: _rewardAnimation,
          builder: (context, child) {
            final progress = isShown ? _rewardAnimation.value : 0.0;
            return Transform.scale(
              scale: progress,
              child: Opacity(
                opacity: progress,
                child: _buildRewardCard(reward),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRewardCard(RewardItem reward) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reward.color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: reward.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              reward.icon,
              color: reward.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+${reward.amount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            reward.name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(_particleController.value),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int i = 0; i < 30; i++) {
      final radius = 100 + (progress * 300) % 400;
      final x = size.width / 2 + radius * (i % 2 == 0 ? 1 : -1) * (progress * 2 - 1);
      final y = size.height / 2 + radius * (i % 3 == 0 ? 1 : -1) * (progress * 2 - 1);

      canvas.drawCircle(
        Offset(
          size.width / 2 + (x - size.width / 2) * 0.5,
          size.height / 2 + (y - size.height / 2) * 0.5,
        ),
        4.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 진행 상태 표시 위젯
class ProgressionHUD extends StatelessWidget {
  final PlayerProgress progress;

  const ProgressionHUD({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 레벨 배지
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF6F00)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${progress.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // XP 바
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '레벨 ${progress.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${progress.currentXP}/${progress.xpToNextLevel} XP',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 120,
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress.xpProgress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // 트로피
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${progress.totalTrophies}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 연승 표시
          if (progress.winStreak >= 3) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.winStreak}연승',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
