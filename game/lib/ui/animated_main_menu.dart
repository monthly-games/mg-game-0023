import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 화려한 애니메이션이 있는 메인 메뉴
/// 플레이어의 시각적 관심을 지속적으로 유지
class AnimatedMainMenu extends StatefulWidget {
  final VoidCallback onPlayColony;
  final VoidCallback onStartGame;
  final VoidCallback onLevels;
  final VoidCallback onTutorial;
  final VoidCallback onRewards;
  final VoidCallback onDaily;
  final VoidCallback onBattle; // 슈퍼셀 스타일 배틀 추가

  const AnimatedMainMenu({
    super.key,
    required this.onPlayColony,
    required this.onStartGame,
    required this.onLevels,
    required this.onTutorial,
    required this.onRewards,
    required this.onDaily,
    required this.onBattle,
  });

  @override
  State<AnimatedMainMenu> createState() => _AnimatedMainMenuState();
}

class _AnimatedMainMenuState extends State<AnimatedMainMenu>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _bgAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final math.Random _rng = math.Random();
  final List<FloatingElement> _floatingElements = [];

  @override
  void initState() {
    super.initState();

    // 배경 그라데이션 애니메이션
    _bgController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _bgAnimation = Tween<double>(begin: 0, end: 1).animate(_bgController);

    // 플로팅 요소 애니메이션
    _floatController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(_floatController);

    // 펄스 애니메이션
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // 플로팅 요소 생성
    _generateFloatingElements();
  }

  void _generateFloatingElements() {
    final icons = [
      {'icon': Icons.rocket_launch, 'color': const Color(0xFF43A047)},
      {'icon': Icons.energy_savings_leaf, 'color': const Color(0xFFFFD700)},
      {'icon': Icons.science, 'color': const Color(0xFF2196F3)},
      {'icon': Icons.people, 'color': const Color(0xFFE91E63)},
      {'icon': Icons.home_work, 'color': const Color(0xFFFF9800)},
      {'icon': Icons.auto_awesome, 'color': const Color(0xFF9C27B0)},
    ];

    for (int i = 0; i < 12; i++) {
      final iconData = icons[i % icons.length];
      _floatingElements.add(FloatingElement(
        icon: iconData['icon'] as IconData,
        color: iconData['color'] as Color,
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 20 + 24,
        speed: _rng.nextDouble() * 0.2 + 0.05,
        phase: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFF0D1347),
              Color(0xFF1A237E),
              Color(0xFF283593),
              Color(0xFF1A237E),
              Color(0xFF0D1347),
            ],
            stops: [
              _bgAnimation.value,
              (_bgAnimation.value + 0.25) % 1.0,
              (_bgAnimation.value + 0.5) % 1.0,
              (_bgAnimation.value + 0.75) % 1.0,
              _bgAnimation.value + 1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            // 배경 플로팅 요소들
            ..._buildFloatingElements(),

            // 별빛 효과
            ..._buildStars(),

            // 메인 컨텐츠
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 게임 타이틀 섹션
                        _buildTitleSection(),

                        const SizedBox(height: 32),

                        // 메인 플레이 버튼
                        _buildMainPlayButton(),

                        const SizedBox(height: 16),

                        // 슈퍼셀 스타일: 즉시 배틀 버튼
                        _buildInstantBattleButton(),

                        const SizedBox(height: 16),

                        // 보조 버튼들
                        _buildSecondaryButtons(),

                        const SizedBox(height: 24),

                        // 퀵 액션 버튼들
                        _buildQuickActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 상태바 장식
            _buildStatusBarDecoration(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        // 빛나는 로고
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: _pulseAnimation.value * 0.4),
                    blurRadius: 25 * _pulseAnimation.value,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD700), Color(0xFFFF6F00)],
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // 게임 ID
        const Text(
          'MG-0023',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Colors.white54,
          ),
        ),

        const SizedBox(height: 8),

        // 게임 타이틀
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFFFFF), Color(0xFFFFD700)],
          ).createShader(bounds),
          child: const Text(
            'COLONY FRONTIER',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 서브타이틀
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.2),
                Colors.blue.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            '콜로니를 건설하고 새로운 문명을 시작하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainPlayButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: _pulseAnimation.value * 0.4),
                blurRadius: 20 * _pulseAnimation.value,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FilledButton(
            key: const ValueKey('play-colony'),
            onPressed: widget.onPlayColony,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, size: 32),
                SizedBox(width: 12),
                Text(
                  '게임 시작',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstantBattleButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: _pulseAnimation.value * 0.4),
                blurRadius: 20 * _pulseAnimation.value,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: widget.onBattle,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '⚡ 즉시 배틀',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '3분',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButtons() {
    return Column(
      children: [
        _buildMenuButton(
          key: const ValueKey('start-game'),
          icon: Icons.videogame_asset_rounded,
          label: '프로토타입',
          onTap: widget.onStartGame,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 8),
        _buildMenuButton(
          key: const ValueKey('level-roadmap'),
          icon: Icons.map_rounded,
          label: '레벨 로드맵',
          onTap: widget.onLevels,
          color: const Color(0xFFFF9800),
        ),
        const SizedBox(height: 8),
        _buildMenuButton(
          key: const ValueKey('tutorial'),
          icon: Icons.school_rounded,
          label: '튜토리얼',
          onTap: widget.onTutorial,
          color: const Color(0xFF9C27B0),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: OutlinedButton(
        key: key,
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '퀵 액션',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  key: const ValueKey('daily-quests'),
                  icon: Icons.today_rounded,
                  label: '데일리',
                  onTap: widget.onDaily,
                  color: const Color(0xFFFF6F00),
                  isHighlighted: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  key: const ValueKey('rewards'),
                  icon: Icons.card_giftcard_rounded,
                  label: '보상',
                  onTap: widget.onRewards,
                  color: const Color(0xFFE91E63),
                  isHighlighted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isHighlighted,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return _floatingElements.map((element) {
      return AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          final progress = (_floatAnimation.value + element.phase) % 1.0;
          final x = element.x + math.sin(progress * math.pi * 2) * 0.1;
          final y = (element.y + progress * element.speed) % 1.0;

          return Positioned(
            left: x * MediaQuery.of(context).size.width,
            top: y * MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                element.icon,
                color: element.color,
                size: element.size,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> _buildStars() {
    final stars = <Widget>[];
    for (int i = 0; i < 50; i++) {
      final x = _rng.nextDouble();
      final y = _rng.nextDouble();
      final size = _rng.nextDouble() * 1.5 + 0.5;
      final opacity = _rng.nextDouble() * 0.3 + 0.1;

      stars.add(
        Positioned(
          left: x * 400, // Limit to smaller area
          top: y * 800,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ),
      );
    }
    return stars;
  }

  Widget _buildStatusBarDecoration() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingElement {
  final IconData icon;
  final Color color;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;

  FloatingElement({
    required this.icon,
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}
