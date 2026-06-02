import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 콜로니스트(인구)의 시각적 표현 - 살아있는 식민지
class ColonyVisualization extends StatefulWidget {
  final int population;
  final int buildingCount;
  final Size gridSize;

  const ColonyVisualization({
    super.key,
    required this.population,
    required this.buildingCount,
    required this.gridSize,
  });

  @override
  State<ColonyVisualization> createState() => _ColonyVisualizationState();
}

class _ColonyVisualizationState extends State<ColonyVisualization>
    with TickerProviderStateMixin {
  late AnimationController _movementController;
  final List<Colonist> _colonists = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();

    _movementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 인구수에 따라 콜로니스트 생성
    _updateColonists();

    _movementController.addListener(() {
      setState(() {
        _updateColonistPositions();
      });
    });
  }

  @override
  void didUpdateWidget(ColonyVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.population != oldWidget.population) {
      _updateColonists();
    }
  }

  void _updateColonists() {
    // 화면에 표시할 콜로니스트 수 (최대 15개)
    final displayCount = widget.population.clamp(1, 15);

    _colonists.clear();
    for (int i = 0; i < displayCount; i++) {
      _colonists.add(Colonist(
        id: i,
        emoji: _getRandomColonistEmoji(),
        position: _getRandomPosition(),
        targetPosition: Offset.zero,
        speed: 0.3 + _rng.nextDouble() * 0.4,
        scale: 0.6 + _rng.nextDouble() * 0.4,
      ));
    }
  }

  void _updateColonistPositions() {
    for (final colonist in _colonists) {
      colonist.update(_movementController.value, widget.gridSize);
    }
  }

  String _getRandomColonistEmoji() {
    const emojis = [
      '👨‍🚀', '👩‍🚀', '🧑‍🚀', '👨‍💻', '👩‍💻',
      '👷', '👷‍♀️', '👨‍🔧', '👩‍🔧', '🧑‍🔬',
      '👨‍🏫', '👩‍🏫', '👮', '👮‍♀️', '🧑‍⚕️',
    ];
    return emojis[_rng.nextInt(emojis.length)];
  }

  Offset _getRandomPosition() {
    return Offset(
      _rng.nextDouble() * widget.gridSize.width,
      _rng.nextDouble() * widget.gridSize.height,
    );
  }

  @override
  void dispose() {
    _movementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 콜로니스트들
        ..._colonists.map((colonist) => Positioned(
              left: colonist.position.dx,
              top: colonist.position.dy,
              child: Transform.scale(
                scale: colonist.scale,
                child: Opacity(
                  opacity: 0.7 + colonist.scale * 0.3,
                  child: Text(
                    colonist.emoji,
                    style: TextStyle(
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
        // 인구 정보 배지
        Positioned(
          top: 8,
          right: 8,
          child: _PopulationBadge(
            population: widget.population,
            colonists: _colonists,
          ),
        ),
      ],
    );
  }
}

class Colonist {
  final int id;
  final String emoji;
  Offset position;
  Offset targetPosition;
  final double speed;
  final double scale;

  Colonist({
    required this.id,
    required this.emoji,
    required this.position,
    required this.targetPosition,
    required this.speed,
    required this.scale,
  });

  void update(double progress, Size bounds) {
    // 목표 지점에 도달하면 새 목표 설정
    if ((targetPosition - position).distance < 10) {
      targetPosition = Offset(
        math.Random().nextDouble() * (bounds.width - 30),
        math.Random().nextDouble() * (bounds.height - 30),
      );
    }

    // 부드럽게 이동
    position = Offset.lerp(position, targetPosition, 0.02 * speed) ?? position;
  }
}

class _PopulationBadge extends StatelessWidget {
  final int population;
  final List<Colonist> colonists;

  const _PopulationBadge({
    required this.population,
    required this.colonists,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '👥',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            '$population',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 건물별 작업 표시 위젯
class BuildingWorkIndicator extends StatelessWidget {
  final String buildingType;
  final bool isProducing;
  final double productionRate;

  const BuildingWorkIndicator({
    super.key,
    required this.buildingType,
    required this.isProducing,
    required this.productionRate,
  });

  @override
  Widget build(BuildContext context) {
    if (!isProducing) return const SizedBox.shrink();

    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _WorkParticles(productionRate: productionRate),
      ),
    );
  }
}

class _WorkParticles extends StatefulWidget {
  final double productionRate;

  const _WorkParticles({required this.productionRate});

  @override
  State<_WorkParticles> createState() => _WorkParticlesState();
}

class _WorkParticlesState extends State<_WorkParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1000 / widget.productionRate).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(3, (index) {
            final progress = ((_controller.value + index * 0.33) % 1.0);
            return Positioned(
              bottom: progress * 30,
              left: 10 + _rng.nextDouble() * 20,
              child: Opacity(
                opacity: 1 - progress,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getProductionColor(),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Color _getProductionColor() {
    return const Color(0xFFFFD700); // Gold particles
  }
}

/// 콜로니 활기 표시 오버레이
class ColonyLifeOverlay extends StatelessWidget {
  final Widget child;
  final int population;
  final int buildingCount;

  const ColonyLifeOverlay({
    super.key,
    required this.child,
    required this.population,
    required this.buildingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // 콜로니스트들이 돌아다니는 레이어
        if (population > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: ColonyVisualization(
                population: population,
                buildingCount: buildingCount,
                gridSize: const Size(400, 600),
              ),
            ),
          ),
      ],
    );
  }
}
