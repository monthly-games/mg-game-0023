import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flame_audio/flame_audio.dart';

/// 건물 건설 완료 시 성취감을 주는 연출 효과
class ConstructionCompletionEffect extends StatefulWidget {
  final String buildingName;
  final Offset position;
  final VoidCallback? onComplete;

  const ConstructionCompletionEffect({
    super.key,
    required this.buildingName,
    required this.position,
    this.onComplete,
  });

  @override
  State<ConstructionCompletionEffect> createState() =>
      _ConstructionCompletionEffectState();
}

class _ConstructionCompletionEffectState
    extends State<ConstructionCompletionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // 완성 사운드 재생
    FlameAudio.play('sfx_build_complete.wav');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // 애니메이션 완료 후 콜백
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 60,
      top: widget.position.dy - 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value *
                (1 - _particleAnimation.value.clamp(0.7, 1.0).map(0.7, 1.0, 0.0, 1.0)),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _CompletionPopup(
                buildingName: widget.buildingName,
                particleProgress: _particleAnimation.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompletionPopup extends StatelessWidget {
  final String buildingName;
  final double particleProgress;

  const _CompletionPopup({
    required this.buildingName,
    required this.particleProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFD700), // Gold
            Color(0xFFFFA500), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'CONSTRUCTION COMPLETE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            buildingName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 파티클 효과 (빛 방출)
          if (particleProgress < 0.8)
            ...List.generate(8, (index) {
              final angle = (index / 8) * 6.28;
              final distance = particleProgress * 50;
              return Positioned.fill(
                child: Transform.translate(
                  offset: Offset(
                    (angle * distance).clamp(-30.0, 30.0),
                    (angle * distance * 0.5).clamp(-20.0, 20.0),
                  ),
                  child: Opacity(
                    opacity: 1 - particleProgress.clamp(0.5, 0.8).map(0.5, 0.8, 1.0, 0.0),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

extension _DoubleExtension on double {
  double map(double start1, double stop1, double start2, double stop2) {
    return start2 + (stop2 - start2) * ((this - start1) / (stop1 - start1));
  }
}

/// 건설 효과를 관리하는 전역 오버레이
class ConstructionEffectOverlay extends StatefulWidget {
  final Widget child;

  const ConstructionEffectOverlay({
    super.key,
    required this.child,
  });

  @override
  State<ConstructionEffectOverlay> createState() =>
      _ConstructionEffectOverlayState();
}

class _ConstructionEffectOverlayState extends State<ConstructionEffectOverlay> {
  final List<_ConstructionEffectData> _effects = [];

  void showEffect(String buildingName, Offset position) {
    setState(() {
      _effects.add(_ConstructionEffectData(
        buildingName: buildingName,
        position: position,
        key: UniqueKey(),
      ));
    });

    // 2초 후 제거
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _effects.removeWhere((e) => e.key == _effects.last.key);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._effects.map((effect) => ConstructionCompletionEffect(
              key: effect.key,
              buildingName: effect.buildingName,
              position: effect.position,
            )),
      ],
    );
  }
}

class _ConstructionEffectData {
  final String buildingName;
  final Offset position;
  final Key key;

  _ConstructionEffectData({
    required this.buildingName,
    required this.position,
    required this.key,
  });
}
