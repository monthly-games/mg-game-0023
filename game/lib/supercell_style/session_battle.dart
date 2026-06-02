import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

/// 슈퍼셀 스타일 세션 배틀 시스템
/// - 짧고 강렬한 3-5분 세션
/// - 즉시 플레이 가능
/// - "한 번 더"의 중독성 루프
class SessionBattleScreen extends StatefulWidget {
  const SessionBattleScreen({super.key});

  @override
  State<SessionBattleScreen> createState() => _SessionBattleScreenState();
}

class _SessionBattleScreenState extends State<SessionBattleScreen>
    with TickerProviderStateMixin {
  // 게임 상태
  int _sessionTime = 180; // 3분 세션
  int _playerHealth = 100;
  int _enemyHealth = 100;
  int _elixir = 4; // 슈퍼셀 스타일 엘릭서
  final int _maxElixir = 10;
  bool _isGameOver = false;

  // 애니메이션
  late AnimationController _battleController;
  late AnimationController _elixirController;
  late AnimationController _cardController;

  // 카드 덱 (슈퍼셀 스타일)
  final List<BattleCard> _deck = _generateDeck();
  final List<BattleCard> _hand = [];
  final int _selectedCardIndex = -1;

  // 엘릭서 재생 타이머
  Timer? _elixirTimer;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();

    _battleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _elixirController = AnimationController(
      duration: const Duration(milliseconds: 2800), // 2.8秒마다 엘릭서 +1
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 초기 카드 4장
    _drawCards(4);

    // 엘릭서 타이머 시작
    _startElixirTimer();

    // 세션 타이머 시작
    _startSessionTimer();
  }

  static List<BattleCard> _generateDeck() {
    return [
      BattleCard(
        id: '1',
        name: '건설부대',
        elixir: 3,
        icon: Icons.construction,
        color: Colors.amber,
        damage: 15,
        description: '건물을 신속하게 건설',
      ),
      BattleCard(
        id: '2',
        name: '방어진',
        elixir: 4,
        icon: Icons.security,
        color: Colors.blue,
        damage: 10,
        description: '적의 공격을 방어',
      ),
      BattleCard(
        id: '3',
        name: '에너지파',
        elixir: 5,
        icon: Icons.bolt,
        color: Colors.purple,
        damage: 30,
        description: '강력한 에너지 파동',
      ),
      BattleCard(
        id: '4',
        name: '수리드론',
        elixir: 2,
        icon: Icons.build,
        color: Colors.green,
        damage: 10,
        description: '건물을 수리하고 보호',
      ),
      BattleCard(
        id: '5',
        name: '특수부대',
        elixir: 4,
        icon: Icons.military_tech,
        color: Colors.red,
        damage: 20,
        description: '특수 임무 수행',
      ),
      BattleCard(
        id: '6',
        name: '자원수집',
        elixir: 1,
        icon: Icons.inventory,
        color: Colors.teal,
        damage: 5,
        description: '자원을 빠르게 획득',
      ),
      BattleCard(
        id: '7',
        name: '공성포',
        elixir: 6,
        icon: Icons.gps_fixed,
        color: Colors.orange,
        damage: 40,
        description: '강력한 공성 무기',
      ),
      BattleCard(
        id: '8',
        name: '전술스캔',
        elixir: 2,
        icon: Icons.radar,
        color: Colors.cyan,
        damage: 8,
        description: '적 정보 획득',
      ),
    ];
  }

  void _drawCards(int count) {
    for (int i = 0; i < count && _hand.length < 4; i++) {
      if (_deck.isNotEmpty) {
        final card = _deck.removeAt(0);
        _hand.add(card);
        _deck.add(card); // 덱에 다시 추가
      }
    }
    setState(() {});
  }

  void _startElixirTimer() {
    _elixirTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_elixir < _maxElixir && !_isGameOver) {
        setState(() {
          _elixir++;
        });
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sessionTime > 0 && !_isGameOver) {
        setState(() {
          _sessionTime--;
        });
      } else if (_sessionTime == 0 && !_isGameOver) {
        _endGame();
      }
    });
  }

  void _playCard(int index) {
    if (_isGameOver) return;

    final card = _hand[index];
    if (_elixir < card.elixir) {
      // 엘릭서 부족 효과
      _battleController.forward().then((_) => _battleController.reverse());
      return;
    }

    // 카드 사용
    setState(() {
      _elixir -= card.elixir;
      _enemyHealth = math.max(0, _enemyHealth - card.damage);
      _hand.removeAt(index);
      _drawCards(1);
    });

    _cardController.forward().then((_) => _cardController.reverse());

    // 적 반격
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isGameOver) {
        setState(() {
          _playerHealth = math.max(0, _playerHealth - math.Random().nextInt(15));
        });

        if (_playerHealth <= 0 || _enemyHealth <= 0) {
          _endGame();
        }
      }
    });
  }

  void _endGame() {
    setState(() {
      _isGameOver = true;
    });
    _elixirTimer?.cancel();
    _sessionTimer?.cancel();
  }

  @override
  void dispose() {
    _battleController.dispose();
    _elixirController.dispose();
    _cardController.dispose();
    _elixirTimer?.cancel();
    _sessionTimer?.cancel();
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
              Color(0xFF1A237E), // Deep blue
              Color(0xFF311B92), // Purple
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: SafeArea(
          child: _isGameOver ? _buildGameOverScreen() : _buildBattleScreen(),
        ),
      ),
    );
  }

  Widget _buildBattleScreen() {
    return Column(
      children: [
        // 상단: 적 정보
        _buildEnemyInfo(),

        // 중앙: 배틀 필드
        Expanded(
          child: _buildBattleField(),
        ),

        // 하단: 플레이어 UI
        _buildPlayerUI(),
      ],
    );
  }

  Widget _buildEnemyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 타이머
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${(_sessionTime ~/ 60)}:${(_sessionTime % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 적 체력 바
          _buildHealthBar('적 콜로니', _enemyHealth, Colors.red),
        ],
      ),
    );
  }

  Widget _buildBattleField() {
    return Stack(
      children: [
        // 배경 그리드
        ..._buildGridLines(),

        // 전투 애니메이션
        Center(
          child: AnimatedBuilder(
            animation: _cardController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_cardController.value * 0.1),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow.withValues(alpha: 0.3 * _cardController.value),
                    border: Border.all(
                      color: Colors.yellow.withValues(alpha: _cardController.value),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: Colors.yellow.withValues(alpha: _cardController.value),
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ),

        // 진행 상황 표시
        Positioned(
          top: 20,
          left: 20,
          child: _buildBattleStats(),
        ),
      ],
    );
  }

  Widget _buildPlayerUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 엘릭서 바
          _buildElixirBar(),

          const SizedBox(height: 12),

          // 카드 핸드
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_hand.length, (index) {
              return _buildCard(_hand[index], index);
            }),
          ),

          const SizedBox(height: 8),

          // 즉시 배틀 버튼 (첫 플레이 유도)
          if (_sessionTime > 150)
            FilledButton.icon(
              onPressed: () => _playCard(0),
              icon: const Icon(Icons.play_arrow),
              label: const Text('카드를 선택하세요!'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildElixirBar() {
    return Row(
      children: [
        ...List.generate(_maxElixir, (index) {
          final filled = index < _elixir;
          return Container(
            width: 28,
            height: 32,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: filled ? Colors.purple : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: filled ? Colors.purpleAccent : Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: filled
                ? const Icon(Icons.bolt, color: Colors.white, size: 16)
                : null,
          );
        }),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'ELIXIR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BattleCard card, int index) {
    final canAfford = _elixir >= card.elixir;
    final isSelected = _selectedCardIndex == index;

    return GestureDetector(
      onTap: () => _playCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 90,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: canAfford
                ? [card.color.withValues(alpha: 0.8), card.color]
                : [Colors.grey.withValues(alpha: 0.5), Colors.grey.withValues(alpha: 0.3)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canAfford
                ? (isSelected ? Colors.yellow : Colors.white)
                : Colors.grey,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: canAfford
              ? [
                  BoxShadow(
                    color: card.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 엘릭서 비용
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${card.elixir}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 카드 아이콘
            Icon(card.icon, color: Colors.white, size: 32),

            const SizedBox(height: 4),

            // 데미지
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on, color: Colors.red, size: 14),
                Text(
                  '${card.damage}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar(String label, int health, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: health / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '$health%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBattleStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '배틀 통계',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatItem('데미지', '${100 - _enemyHealth}', Colors.red),
          _buildStatItem('방어', '${100 - _playerHealth}', Colors.blue),
          _buildStatItem('사용 카드', '${4 - _hand.length}', Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGridLines() {
    final lines = <Widget>[];
    for (int i = 1; i < 6; i++) {
      lines.add(
        Positioned(
          left: 0,
          right: 0,
          top: i * 120,
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      );
    }
    return lines;
  }

  Widget _buildGameOverScreen() {
    final isVictory = _enemyHealth <= 0 || _playerHealth > _enemyHealth;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isVictory
              ? [const Color(0xFFFFD700), const Color(0xFFFF6F00)]
              : [const Color(0xFF37474F), const Color(0xFF263238)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVictory ? Icons.emoji_events : Icons.close,
              size: 100,
              color: isVictory ? Colors.white : Colors.white.withValues(alpha: 0.5),
            ),

            const SizedBox(height: 24),

            Text(
              isVictory ? '승리!' : '패배',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              isVictory ? '콜로니를 방어했습니다!' : '다음에 다시 도전하세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(height: 32),

            // "한 번 더" 버튼 (슈퍼셀 스타일 중독성 루프)
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // 같은 화면으로 다시 이동 (재시작)
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SessionBattleScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.replay),
              label: const Text('한 번 더'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 56),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 배틀 카드 (슈퍼셀 스타일)
class BattleCard {
  final String id;
  final String name;
  final int elixir;
  final IconData icon;
  final Color color;
  final int damage;
  final String description;

  BattleCard({
    required this.id,
    required this.name,
    required this.elixir,
    required this.icon,
    required this.color,
    required this.damage,
    required this.description,
  });
}
