import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flame_audio/flame_audio.dart';

/// 레벨업 시 화려한 쇼케이스 효과
class LevelUpShowcase extends StatefulWidget {
  final int newLevel;
  final int goldReward;
  final int xpReward;
  final VoidCallback? onComplete;

  const LevelUpShowcase({
    super.key,
    required this.newLevel,
    required this.goldReward,
    required this.xpReward,
    this.onComplete,
  });

  @override
  State<LevelUpShowcase> createState() => _LevelUpShowcaseState();
}

class _LevelUpShowcaseState extends State<LevelUpShowcase>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleExpandAnimation;
  late Animation<double> _glowPulseAnimation;

  bool _showRewards = false;

  @override
  void initState() {
    super.initState();

    // 레벨업 사운드
    FlameAudio.play('sfx_level_up.wav');

    // 메인 애니메이션 컨트롤러
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _particleExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.easeOut,
      ),
    );

    _glowPulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();

    // 보상 표시 타이밍
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _showRewards = true);
        FlameAudio.play('sfx_reward_pop.wav');
      }
    });

    // 완료 후 콜백
    Future.delayed(const Duration(milliseconds: 2500), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_mainController, _glowController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _LevelUpCard(
                  newLevel: widget.newLevel,
                  goldReward: widget.goldReward,
                  xpReward: widget.xpReward,
                  showRewards: _showRewards,
                  particleProgress: _particleExpandAnimation.value,
                  glowIntensity: _glowPulseAnimation.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LevelUpCard extends StatelessWidget {
  final int newLevel;
  final int goldReward;
  final int xpReward;
  final bool showRewards;
  final double particleProgress;
  final double glowIntensity;

  const _LevelUpCard({
    required this.newLevel,
    required this.goldReward,
    required this.xpReward,
    required this.showRewards,
    required this.particleProgress,
    required this.glowIntensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo
            Color(0xFF8B5CF6), // Purple
            Color(0xFFA855F7), // Purple Light
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.5 * glowIntensity),
            blurRadius: 30 * glowIntensity,
            spreadRadius: 10 * glowIntensity,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 레벨업 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.8 * glowIntensity),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          // LEVEL UP 텍스트
          const Text(
            'LEVEL UP!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 새 레벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level $newLevel',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 보상 섹션
          if (showRewards) ...[
            _RewardItem(
              icon: Icons.monetization_on,
              label: 'Gold',
              value: '+$goldReward',
              color: Colors.amber,
              delay: 0,
            ),
            const SizedBox(height: 12),
            _RewardItem(
              icon: Icons.stars,
              label: 'Experience',
              value: '+$xpReward',
              color: Colors.cyan,
              delay: 1,
            ),
          ],
          // 파티클 효과
          ..._buildParticles(),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(12, (index) {
      final angle = (index / 12) * 6.28;
      final distance = particleProgress * 120;
      return Positioned.fill(
        child: Center(
          child: Transform.translate(
            offset: Offset(
              (angle * distance).clamp(-60.0, 60.0),
              (angle * distance * 0.5).clamp(-40.0, 40.0),
            ),
            child: Opacity(
              opacity: (1 - particleProgress.clamp(0.5, 1.0).map(0.5, 1.0, 1.0, 0.0)),
              child: Container(
                width: 8 - (particleProgress * 4),
                height: 8 - (particleProgress * 4),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.amber : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _RewardItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

extension on double {
  double map(double start1, double stop1, double start2, double stop2) {
    return start2 + (stop2 - start2) * ((this - start1) / (stop1 - start1));
  }
}
