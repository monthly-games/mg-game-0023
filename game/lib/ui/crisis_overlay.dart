import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flame_audio/flame_audio.dart';

/// 위기 상태 오버레이 - 긴장감을 극대화하는 시각/청각 효과
class CrisisOverlay extends StatefulWidget {
  final bool isCrisis;
  final Widget child;

  const CrisisOverlay({
    super.key,
    required this.isCrisis,
    required this.child,
  });

  @override
  State<CrisisOverlay> createState() => _CrisisOverlayState();
}

class _CrisisOverlayState extends State<CrisisOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _sirenTimer;
  bool _isPlayingSiren = false;

  @override
  void initState() {
    super.initState();

    // 깜빡임 애니메이션 설정 (0.5초 주기)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(CrisisOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCrisis != oldWidget.isCrisis) {
      if (widget.isCrisis) {
        _startCrisisEffects();
      } else {
        _stopCrisisEffects();
      }
    }
  }

  void _startCrisisEffects() {
    _pulseController.forward();

    // 사이렌 소리 시작 (1.5초 간격)
    if (!_isPlayingSiren) {
      _isPlayingSiren = true;
      _sirenTimer = Timer.periodic(
        const Duration(milliseconds: 1500),
        (_) => FlameAudio.play('sfx_alarm.wav'),
      );
    }
  }

  void _stopCrisisEffects() {
    _pulseController.stop();
    _sirenTimer?.cancel();
    _sirenTimer = null;
    _isPlayingSiren = false;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sirenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isCrisis) ...[
          // 붉은색 깜빡임 오버레이
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.red.withValues(
                  alpha: 0.15 + (_pulseAnimation.value * 0.15),
                ),
              );
            },
          ),
          // 비상 테두리
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red.withValues(
                        alpha: 0.5 + (_pulseAnimation.value * 0.5),
                      ),
                      width: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          // 위기 메시지
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: _CrisisAlertMessage(
              pulseAnimation: _pulseAnimation,
            ),
          ),
        ],
      ],
    );
  }
}

class _CrisisAlertMessage extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const _CrisisAlertMessage({required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (pulseAnimation.value * 0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'CRITICAL ALERT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'VITAL RESOURCES DEPLETED!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Act immediately or colonists will die!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
