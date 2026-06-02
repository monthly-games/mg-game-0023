library;

/// 실제 플레이 가능한 레인 방어 게임
/// - 적이 실제로 스폰됨
/// - 타이밍에 맞춰 탭하여 방어
/// - 레벨별 난이도 조절
/// - 튜토리얼 포함

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';

/// 실제 게임플레이가 있는 게임 화면
class RealGameScreen extends StatefulWidget {
  const RealGameScreen({super.key});

  @override
  State<RealGameScreen> createState() => _RealGameScreenState();
}

class _RealGameScreenState extends State<RealGameScreen>
    with TickerProviderStateMixin {
  // 게임 상태
  int levelIndex = 0;
  int goldBank = 0;
  int xpBank = 0;
  bool gameOver = false;
  bool levelComplete = false;
  bool showTutorial = true;

  // 콤보 시스템
  int comboCount = 0;
  int maxCombo = 0;
  DateTime? lastKillTime;
  static const int comboTimeoutMs = 2000; // 2초 내에 처치하면 콤보 유지

  // 웨이브 관리
  List<Enemy> enemies = [];
  int enemiesSpawned = 0;
  int enemiesKilled = 0;
  int enemiesPassed = 0;
  static const int maxEnemiesPassed = 3; // 3마리 지나면 게임 오버

  // 스폰 타이머
  Timer? spawnTimer;
  Timer? gameTimer;

  // 애니메이션
  late AnimationController _gameController;
  late AnimationController _enemyController;

  // 탭 효과
  List<TapEffect> tapEffects = [];

  // 게임 시간
  int gameSeconds = 0;

  GameLevelDesign get currentLevel => kLevelDesign[levelIndex];
  WaveSpawnEntry get spawnConfig => kWaveSpawnTable[levelIndex];

  @override
  void initState() {
    super.initState();

    _gameController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _enemyController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat();

    startLevel();
  }

  @override
  void dispose() {
    _gameController.dispose();
    _enemyController.dispose();
    spawnTimer?.cancel();
    gameTimer?.cancel();
    super.dispose();
  }

  void startLevel() {
    setState(() {
      enemies.clear();
      enemiesSpawned = 0;
      enemiesKilled = 0;
      enemiesPassed = 0;
      gameOver = false;
      levelComplete = false;
      gameSeconds = 0;
      // 콤보 초기화
      comboCount = 0;
      maxCombo = 0;
      lastKillTime = null;
    });

    // 스폰 타이머 시작
    final spawnIntervalMs = (spawnConfig.spawnCadenceSeconds * 1000).round();
    spawnTimer = Timer.periodic(
      Duration(milliseconds: spawnIntervalMs),
      (_) => spawnEnemy(),
    );

    // 게임 타이머
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        gameSeconds++;
      });
    });
  }

  void spawnEnemy() {
    if (gameOver || levelComplete) return;

    final totalEnemies = spawnConfig.enemyCount;
    if (enemiesSpawned >= totalEnemies) {
      // 모든 적 스폰 완료
      checkWaveComplete();
      return;
    }

    final lane = math.Random().nextInt(3); // 3개 레인 중 하나
    final baseSpeed = 0.3 + (currentLevel.difficulty * 0.1);

    // 레벨에 따른 다양한 적 타입 스폰
    EnemyType enemyType = EnemyType.normal;
    final rand = math.Random().nextDouble();

    if (levelIndex >= 5 && rand < 0.1) {
      // Level 5+ : 10% 확률로 보스
      enemyType = EnemyType.boss;
    } else if (levelIndex >= 3 && rand < 0.2) {
      // Level 3+ : 20% 확률로 튼튼한 적
      enemyType = EnemyType.tank;
    } else if (levelIndex >= 2 && rand < 0.3) {
      // Level 2+ : 30% 확률로 빠른 적
      enemyType = EnemyType.fast;
    }

    setState(() {
      enemies.add(Enemy.create(
        id: DateTime.now().millisecondsSinceEpoch + enemiesSpawned,
        lane: lane,
        speed: baseSpeed,
        type: enemyType,
      ));
      enemiesSpawned++;
    });
  }

  void handleTap(int lane) {
    if (gameOver || levelComplete) return;

    // 가장 가까운 적 찾기
    final tappedLaneEnemies = enemies.where((e) => e.lane == lane).toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));

    if (tappedLaneEnemies.isNotEmpty) {
      final target = tappedLaneEnemies.first;
      final now = DateTime.now();

      // 콤보 체크
      if (lastKillTime != null &&
          now.difference(lastKillTime!).inMilliseconds < comboTimeoutMs) {
        comboCount++;
        if (comboCount > maxCombo) {
          maxCombo = comboCount;
        }
      } else {
        comboCount = 1;
      }
      lastKillTime = now;

      // 탭 효과 추가
      setState(() {
        tapEffects.add(TapEffect(
          lane: lane,
          progress: target.progress,
          timestamp: now,
          combo: comboCount,
        ));

        // 적 HP 감소 (특히 튼튼한 적/보스 처리)
        if (target.hp > 1) {
          // HP가 남으면 적을 업데이트하지 제거하지 않음
          final updatedEnemy = Enemy(
            id: target.id,
            lane: target.lane,
            progress: target.progress,
            speed: target.speed,
            hp: target.hp - 1,
            maxHp: target.maxHp,
            type: target.type,
          );
          enemies[enemies.indexOf(target)] = updatedEnemy;
        } else {
          // 적 완전 처치
          enemies.remove(target);
          enemiesKilled++;

          // 콤보 보너스 (3콤보 이상)
          if (comboCount >= 3) {
            goldBank += comboCount; // 콤보 보너스
          }
        }

        _gameController.forward().then((_) => _gameController.reverse());
      });

      checkWaveComplete();
    } else {
      // 빈 탭 - 콤보 리셋 및 피드백
      setState(() {
        comboCount = 0; // 콤보 리셋
        tapEffects.add(TapEffect(
          lane: lane,
          progress: 0.5,
          timestamp: DateTime.now(),
          isMiss: true,
        ));
      });
    }
  }

  void updateEnemies() {
    if (gameOver || levelComplete) return;

    final deltaTime = 1.0 / 60.0; // 60fps 가정

    setState(() {
      final updatedEnemies = <Enemy>[];

      for (final enemy in enemies) {
        var newEnemy = Enemy(
          id: enemy.id,
          lane: enemy.lane,
          progress: enemy.progress + (enemy.speed * deltaTime),
          speed: enemy.speed,
          hp: enemy.hp,
        );

        // 적이 도착하면
        if (newEnemy.progress >= 1.0) {
          enemiesPassed++;
          if (enemiesPassed >= maxEnemiesPassed) {
            gameOver = true;
            spawnTimer?.cancel();
            gameTimer?.cancel();
          }
        } else {
          updatedEnemies.add(newEnemy);
        }
      }

      enemies = updatedEnemies;

      // 오래된 탭 효과 제거
      final now = DateTime.now();
      tapEffects = tapEffects.where((effect) {
        return now.difference(effect.timestamp).inMilliseconds < 500;
      }).toList();
    });
  }

  void checkWaveComplete() {
    final totalEnemies = spawnConfig.enemyCount;
    if (enemiesKilled + enemiesPassed >= totalEnemies && enemies.isEmpty) {
      if (enemiesPassed < maxEnemiesPassed) {
        // 승리!
        levelComplete = true;
        spawnTimer?.cancel();
        gameTimer?.cancel();
      }
    }
  }

  void completeLevel() {
    setState(() {
      goldBank += currentLevel.goldReward;
      xpBank += currentLevel.xpReward;

      if (levelIndex < kLevelDesign.length - 1) {
        levelIndex++;
      }

      levelComplete = false;
      showTutorial = false; // 튜토리얼 한 번만 표시
    });

    startLevel();
  }

  void restartLevel() {
    setState(() {
      levelIndex = 0;
      goldBank = 0;
      xpBank = 0;
      showTutorial = false;
    });

    startLevel();
  }

  @override
  Widget build(BuildContext context) {
    final level = currentLevel;
    final spawn = spawnConfig;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    // 게임 루프
    if (!gameOver && !levelComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 콤보 타임아웃 체크
        if (lastKillTime != null &&
            DateTime.now().difference(lastKillTime!).inMilliseconds > comboTimeoutMs &&
            comboCount > 0) {
          setState(() {
            comboCount = 0; // 콤보 리셋
          });
        }
        updateEnemies();
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: Text(gameOver ? '게임 오버' : (levelComplete ? '레벨 완료!' : 'Live Run')),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (showTutorial)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                setState(() {
                  showTutorial = false;
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // 배경 그라데이션
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(primary, Colors.white, 0.18)!,
                  Color.lerp(colorScheme.tertiary, Colors.black, 0.18)!,
                  const Color(0xFF172033),
                ],
              ),
            ),
          ),

          // 메인 게임 콘텐츠
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  // 상단 정보 패널
                  _buildTopPanel(level, spawn),

                  // 게임 영역
                  Expanded(
                    child: Stack(
                      children: [
                        // 레인 게임 영역
                        _buildLanes(),

                        // 적 렌더링
                        ...enemies.map((enemy) => _buildEnemy(enemy)),

                        // 탭 효과
                        ...tapEffects.map((effect) => _buildTapEffect(effect)),

                        // 게임 오버 오버레이
                        if (gameOver) _buildGameOverOverlay(),

                        // 레벨 완료 오버레이
                        if (levelComplete) _buildLevelCompleteOverlay(),

                        // 튜토리얼 오버레이
                        if (showTutorial) _buildTutorialOverlay(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPanel(GameLevelDesign level, WaveSpawnEntry spawn) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 레벨 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${level.levelIndex} - ${level.stage}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    level.objective,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$enemiesKilled / ${spawn.enemyCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '처치: $enemiesPassed / $maxEnemiesPassed',
                    style: TextStyle(
                      color: enemiesPassed >= 2 ? Colors.red : Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: enemiesPassed >= 2 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 메트릭
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricPill(
                icon: Icons.bolt_rounded,
                label: 'Difficulty ${level.difficulty.toStringAsFixed(2)}',
                color: Colors.amber,
              ),
              // 콤보 표시 (3+ 콤보일 때만)
              if (comboCount >= 3)
                _MetricPill(
                  icon: Icons.local_fire_department,
                  label: '${comboCount}x Combo!',
                  color: comboCount >= 5 ? Colors.purple : Colors.orange,
                ),
              _MetricPill(
                icon: Icons.inventory_2_rounded,
                label: '$goldBank gold / $xpBank xp',
                color: Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanes() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => handleTap(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: [
                      const Color(0xFF4CAF50),
                      const Color(0xFF2196F3),
                      const Color(0xFFFF9800),
                    ][i].withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // 레인 배경
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LanePainter(
                          color: [
                            const Color(0xFF4CAF50),
                            const Color(0xFF2196F3),
                            const Color(0xFFFF9800),
                          ][i],
                        ),
                      ),
                    ),

                    // 레인 라인
                    Center(
                      child: Container(
                        width: 2,
                        height: double.infinity,
                        color: [
                          const Color(0xFF4CAF50),
                          const Color(0xFF2196F3),
                          const Color(0xFFFF9800),
                        ][i].withValues(alpha: 0.3),
                      ),
                    ),

                    // 방어 영역 표시
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              [
                                const Color(0xFF4CAF50),
                                const Color(0xFF2196F3),
                                const Color(0xFFFF9800),
                              ][i].withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnemy(Enemy enemy) {
    final laneHeight = MediaQuery.of(context).size.height / 3 - 20;

    // 적 타입별 크기와 색상
    final size = enemy.type == EnemyType.boss ? 55.0 : 40.0;
    Color enemyColor;
    IconData enemyIcon;
    Color shadowColor;

    switch (enemy.type) {
      case EnemyType.normal:
        enemyColor = Colors.red;
        enemyIcon = Icons.error_outline;
        shadowColor = Colors.red;
        break;
      case EnemyType.fast:
        enemyColor = Colors.yellow;
        enemyIcon = Icons.flash_on;
        shadowColor = Colors.yellow;
        break;
      case EnemyType.tank:
        enemyColor = Colors.brown[700]!;
        enemyIcon = Icons.shield;
        shadowColor = Colors.brown;
        break;
      case EnemyType.boss:
        enemyColor = Colors.purple;
        enemyIcon = Icons.stars;
        shadowColor = Colors.purple;
        break;
    }

    // HP 투명도 적용
    final opacity = enemy.opacity;

    return Positioned(
      left: 20 + (enemy.lane * (MediaQuery.of(context).size.width / 3)),
      top: (enemy.lane * laneHeight) + (enemy.progress * (laneHeight - 60)) + 10,
      child: AnimatedBuilder(
        animation: _enemyController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_enemyController.value * 0.1),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enemyColor,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  enemyIcon,
                  color: Colors.white,
                  size: enemy.type == EnemyType.boss ? 30 : 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTapEffect(TapEffect effect) {
    final laneHeight = MediaQuery.of(context).size.height / 3 - 20;

    // 콤보 색상
    Color effectColor;
    if (effect.isMiss) {
      effectColor = Colors.grey;
    } else if (effect.combo >= 5) {
      effectColor = Colors.purple; // 5+ 콤보
    } else if (effect.combo >= 3) {
      effectColor = Colors.orange; // 3-4 콤보
    } else {
      effectColor = Colors.green; // 1-2 콤보
    }

    return Positioned(
      left: 20 + (effect.lane * (MediaQuery.of(context).size.width / 3)),
      top: (effect.lane * laneHeight) + (effect.progress * (laneHeight - 60)) + 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 메인 탭 효과
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: effectColor,
                width: 3,
              ),
            ),
            child: Icon(
              effect.isMiss ? Icons.close : Icons.check,
              color: effectColor,
              size: 30,
            ),
          ),
          // 콤보 표시 (3+ 콤보일 때)
          if (effect.combo >= 3 && !effect.isMiss)
            Positioned(
              top: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: effectColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${effect.combo}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.close,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              '게임 오버!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$enemiesKilled / ${spawnConfig.enemyCount} 적 처치',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: restartLevel,
              icon: const Icon(Icons.replay),
              label: const Text('다시 시작'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCompleteOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              '레벨 완료!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '+${currentLevel.goldReward} gold / +${currentLevel.xpReward} xp',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 콤보 보너스 표시
            if (maxCombo >= 3) ...[
              const SizedBox(height: 8),
              Text(
                '최대 ${maxCombo}x 콤보!',
                style: TextStyle(
                  color: maxCombo >= 5 ? Colors.purple : Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: completeLevel,
              icon: const Icon(Icons.arrow_forward),
              label: Text(levelIndex < kLevelDesign.length - 1 ? '다음 레벨' : '완료!'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2736),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school,
                size: 48,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                '게임 방법',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '• 적이 3개 레인을 따라 이동합니다\n'
                '• 적이 방어선에 도착하기 전에 탭하여 처치하세요\n'
                '• 3마리以上 지나면 게임 오버!\n'
                '• 모든 적을 처치하면 레벨 완료!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  setState(() {
                    showTutorial = false;
                  });
                },
                child: const Text('알겠습니다!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 레인 커스텀 페인터
class _LanePainter extends CustomPainter {
  final Color color;

  const _LanePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // 화살표 그리기
    final path = Path();
    final arrowWidth = size.width * 0.6;
    final arrowX = (size.width - arrowWidth) / 2;

    path.moveTo(arrowX, 20);
    path.lineTo(arrowX + arrowWidth / 2, size.height - 20);
    path.lineTo(arrowX + arrowWidth, 20);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 적 타입
enum EnemyType {
  normal,      // 일반 적
  fast,        // 빠른 적 (1.5x 속도)
  tank,        // 튼튼한 적 (2 HP)
  boss,        // 보스 (3 HP, 큼)
}

/// 적 모델
class Enemy {
  final int id;
  final int lane;
  final double progress;
  final double speed;
  final int hp;
  final int maxHp;
  final EnemyType type;

  Enemy({
    required this.id,
    required this.lane,
    required this.progress,
    required this.speed,
    required this.hp,
    this.maxHp = 1,
    this.type = EnemyType.normal,
  });

  /// 적 생성 팩토리
  factory Enemy.create({
    required int id,
    required int lane,
    required double speed,
    EnemyType type = EnemyType.normal,
  }) {
    switch (type) {
      case EnemyType.normal:
        return Enemy(
          id: id,
          lane: lane,
          progress: 0.0,
          speed: speed,
          hp: 1,
          maxHp: 1,
          type: EnemyType.normal,
        );
      case EnemyType.fast:
        return Enemy(
          id: id,
          lane: lane,
          progress: 0.0,
          speed: speed * 1.5,
          hp: 1,
          maxHp: 1,
          type: EnemyType.fast,
        );
      case EnemyType.tank:
        return Enemy(
          id: id,
          lane: lane,
          progress: 0.0,
          speed: speed * 0.8,
          hp: 2,
          maxHp: 2,
          type: EnemyType.tank,
        );
      case EnemyType.boss:
        return Enemy(
          id: id,
          lane: lane,
          progress: 0.0,
          speed: speed * 0.6,
          hp: 3,
          maxHp: 3,
          type: EnemyType.boss,
        );
    }
  }

  /// 남은 HP에 따른 투명도 (시각적 피드백)
  double get opacity => hp / maxHp;

  /// 적 색상
  String get color {
    switch (type) {
      case EnemyType.normal:
        return '#FF0000'; // 빨간색
      case EnemyType.fast:
        return '#FFFF00'; // 노란색
      case EnemyType.tank:
        return '#8B4513'; // 갈색
      case EnemyType.boss:
        return '#800080'; // 보라색
    }
  }
}

/// 탭 효과 모델
class TapEffect {
  final int lane;
  final double progress;
  final DateTime timestamp;
  final bool isMiss;
  final int combo; // 콤보 수

  TapEffect({
    required this.lane,
    required this.progress,
    required this.timestamp,
    this.isMiss = false,
    this.combo = 0,
  });
}
