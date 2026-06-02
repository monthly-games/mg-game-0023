import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

/// 화려한 인트로 화면 - 게임 시작 시 플레이어의 시선을 사로잡음
/// 파티클 효과, 애니메이션, 역동적인 배경으로 즉각적인 관심 유도
class IntroShowcase extends StatefulWidget {
  final VoidCallback onIntroComplete;

  const IntroShowcase({
    super.key,
    required this.onIntroComplete,
  });

  @override
  State<IntroShowcase> createState() => _IntroShowcaseState();
}

class _IntroShowcaseState extends State<IntroShowcase>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late Animation<double> _titleScale;
  late Animation<double> _titleFade;
  late Animation<double> _glowPulse;

  final List<Particle> _particles = [];
  final math.Random _rng = math.Random();
  Timer? _skipTimer;

  @override
  void initState() {
    super.initState();

    // 제목 애니메이션
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _titleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.elasticOut,
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // 파티클 애니메이션
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // 빛나는 효과
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // 초기 파티클 생성
    _generateParticles(80);

    // 애니메이션 시작
    _startIntro();

    // 5초 후 자동 스킵 가능
    _skipTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {}); // 스킵 버튼 표시
      }
    });
  }

  void _startIntro() {
    _titleController.forward();
  }

  void _generateParticles(int count) {
    for (int i = 0; i < count; i++) {
      _particles.add(Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 3 + 1,
        speed: _rng.nextDouble() * 0.3 + 0.1,
        opacity: _rng.nextDouble() * 0.5 + 0.3,
        color: _getRandomColor(),
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFF43A047), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFFE91E63), // Pink
    ];
    return colors[_rng.nextInt(colors.length)];
  }

  void _skipIntro() {
    _skipTimer?.cancel();
    _titleController.animateTo(1.0);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onIntroComplete();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _skipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.5,
            colors: [
              Color(0xFF1A237E), // Deep Blue
              Color(0xFF0D1347), // Darker Blue
              Color(0xFF000000), // Black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 배경 별들
            ..._buildStars(),

            // 파티클 효과
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                  ),
                );
              },
            ),

            // 중앙 내용
            Center(
              child: AnimatedBuilder(
                animation: _titleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _titleScale.value,
                    child: Opacity(
                      opacity: _titleFade.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 로고 아이콘
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: _glowPulse.value * 0.5),
                                      blurRadius: 30 * _glowPulse.value,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: _glowPulse.value * 0.3),
                                      blurRadius: 50 * _glowPulse.value,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFF6F00),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.rocket_launch_rounded,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),

                          // 게임 ID
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF6F00)],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'MG-0023',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 게임 타이틀
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Text(
                                'COLONY FRONTIER',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFF90CAF9),
                                        Color(0xFFFFFFFF),
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 300, 60),
                                    )
                                    ..maskFilter = const MaskFilter.blur(
                                      BlurStyle.normal,
                                      2,
                                    ),
                                  shadows: [
                                    Shadow(
                                      color: Color.fromRGBO(33, 150, 243, _glowPulse.value),
                                      blurRadius: 20,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // 서브타이틀
                          Text(
                            '🌍 새로운 세계를 건설하세요 🚀',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 핵심 재미 요소 표시
                          _buildFunLoopPills(),

                          const SizedBox(height: 48),

                          // 탭하여 계속 안내
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _titleFade.value * 0.7,
                                child: GestureDetector(
                                  onTap: _skipIntro,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: _glowPulse.value),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '탭하여 시작',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white.withValues(alpha: _glowPulse.value),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 하단 정보
            Positioned(
              bottom: 40,
              child: Opacity(
                opacity: _titleFade.value * 0.5,
                child: const Text(
                  '© 2026 MG Games',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunLoopPills() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildPill('🏗️ 건설', Colors.green),
        _buildPill('⚡ 자원', Colors.amber),
        _buildPill('🔬 연구', Colors.purple),
        _buildPill('👥 생존', Colors.red),
      ],
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    final stars = <Widget>[];
    for (int i = 0; i < 100; i++) {
      final x = _rng.nextDouble();
      final y = _rng.nextDouble();
      final size = _rng.nextDouble() * 2 + 0.5;
      final opacity = _rng.nextDouble() * 0.5 + 0.2;

      stars.add(
        Positioned(
          left: x * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height,
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
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = (particle.y + progress * particle.speed) % 1.0;
      final x = particle.x + math.sin(progress * 2 * math.pi + particle.y * 10) * 0.05;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
