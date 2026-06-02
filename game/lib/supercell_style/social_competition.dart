library;

/// 소셜 경쟁 시스템 - Supercell 스타일 리더보드 및 순위표
/// 플레이어 간 경쟁을 통한 참여도 유도

import 'package:flutter/material.dart';
import 'dart:async';

/// 리더보드 항목 모델
class LeaderboardEntry {
  final String rank;
  final String playerId;
  final String playerName;
  final int score;
  final int trophies;
  final String avatarUrl;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.trophies,
    this.avatarUrl = '',
    this.isCurrentUser = false,
  });

  /// 샘플 리더보드 데이터 생성
  static List<LeaderboardEntry> generateSampleData({String? currentUserId}) {
    return [
      const LeaderboardEntry(
        rank: '1',
        playerId: 'p1',
        playerName: 'LegendColony',
        score: 9850,
        trophies: 2450,
        avatarUrl: '',
      ),
      const LeaderboardEntry(
        rank: '2',
        playerId: 'p2',
        playerName: 'StarBuilder',
        score: 9720,
        trophies: 2380,
        avatarUrl: '',
      ),
      const LeaderboardEntry(
        rank: '3',
        playerId: 'p3',
        playerName: 'CosmicKing',
        score: 9580,
        trophies: 2310,
        avatarUrl: '',
      ),
      const LeaderboardEntry(
        rank: '4',
        playerId: 'p4',
        playerName: 'NovaMaster',
        score: 9450,
        trophies: 2250,
        avatarUrl: '',
      ),
      LeaderboardEntry(
        rank: '5',
        playerId: currentUserId ?? 'p5',
        playerName: 'You',
        score: 9320,
        trophies: 2180,
        avatarUrl: '',
        isCurrentUser: true,
      ),
      const LeaderboardEntry(
        rank: '6',
        playerId: 'p6',
        playerName: 'MoonWalker',
        score: 9200,
        trophies: 2120,
        avatarUrl: '',
      ),
      const LeaderboardEntry(
        rank: '7',
        playerId: 'p7',
        playerName: 'IronForge',
        score: 9080,
        trophies: 2050,
        avatarUrl: '',
      ),
      const LeaderboardEntry(
        rank: '8',
        playerId: 'p8',
        playerName: 'SolarFlare',
        score: 8950,
        trophies: 1990,
        avatarUrl: '',
      ),
      const LeaderboardEntry(
        rank: '9',
        playerId: 'p9',
        playerName: 'VoidWalker',
        score: 8820,
        trophies: 1920,
        avatarUrl: '',
      ),
      const LeaderboardEntry(
        rank: '10',
        playerId: 'p10',
        playerName: 'NebulaStar',
        score: 8700,
        trophies: 1860,
        avatarUrl: '',
      ),
    ];
  }
}

/// 리더보드 타입
enum LeaderboardType {
  global, // 전체 순위
  friends, // 친구 순위
  local, // 지역 순위
  weekly, // 주간 순위
}

/// 소셜 경쟁 화면
class SocialCompetitionScreen extends StatefulWidget {
  const SocialCompetitionScreen({super.key});

  @override
  State<SocialCompetitionScreen> createState() => _SocialCompetitionScreenState();
}

class _SocialCompetitionScreenState extends State<SocialCompetitionScreen>
    with TickerProviderStateMixin {
  LeaderboardType _selectedTab = LeaderboardType.global;
  final List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    // 네트워크 요청 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _entries.clear();
      _entries.addAll(LeaderboardEntry.generateSampleData(currentUserId: 'p5'));
      _isLoading = false;
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
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
              Color(0xFF1A237E),
              Color(0xFF311B92),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingIndicator()
                    : _buildLeaderboardList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '리더보드',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '전체 플레이어 순위',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: const [
                Icon(Icons.military_tech, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '2,180',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: LeaderboardType.values.map((type) {
          final isSelected = _selectedTab == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = type;
                });
                _loadLeaderboard();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.amber.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.amber
                        : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  _getTabLabel(type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.amber : Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTabLabel(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.global:
        return '전체';
      case LeaderboardType.friends:
        return '친구';
      case LeaderboardType.local:
        return '지역';
      case LeaderboardType.weekly:
        return '주간';
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return _buildLeaderboardItem(entry, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final isTop3 = index < 3;
    final rankColor = _getRankColor(index);
    final rankIcon = _getRankIcon(index);

    return AnimatedContainer(
      duration: Duration(milliseconds: 100 + (index * 20)),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: entry.isCurrentUser
            ? LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.3),
                  Colors.orange.withValues(alpha: 0.2),
                ],
              )
            : null,
        color: entry.isCurrentUser
            ? null
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isCurrentUser
              ? Colors.amber
              : Colors.white.withValues(alpha: 0.1),
          width: entry.isCurrentUser ? 2 : 1,
        ),
        boxShadow: entry.isCurrentUser
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // 순위
          SizedBox(
            width: 50,
            child: isTop3
                ? Icon(rankIcon, color: rankColor, size: 32)
                : Text(
                    entry.rank,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          // 아바타
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.6),
                  Colors.purple.withValues(alpha: 0.6),
                ],
              ),
              border: Border.all(
                color: entry.isCurrentUser ? Colors.amber : Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white.withValues(alpha: 0.8),
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          // 플레이어 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.playerName,
                      style: TextStyle(
                        color: entry.isCurrentUser ? Colors.amber : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.score.toLocaleString()} 점',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 트로피
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  entry.trophies.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // 금
      case 1:
        return const Color(0xFFC0C0C0); // 은
      case 2:
        return const Color(0xFFCD7F32); // 동
      default:
        return Colors.white.withValues(alpha: 0.7);
    }
  }

  IconData _getRankIcon(int index) {
    switch (index) {
      case 0:
        return Icons.looks_one;
      case 1:
        return Icons.looks_two;
      case 2:
        return Icons.looks_3;
      default:
        return Icons.emoji_events;
    }
  }
}

extension IntExtension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
