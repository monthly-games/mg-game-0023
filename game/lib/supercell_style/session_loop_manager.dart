library;

/// 세션 기반 게임플레이 루프 매니저
/// Supercell 스타일 짧고 강렬한 세션의 "한 번 더" 루프 구현

import 'package:flutter/material.dart';
import 'dart:async';

/// 세션 결과
enum SessionResult {
  victory,
  defeat,
  timeout,
  disconnected,
}

/// 세션 통계
class SessionStats {
  final int totalSessions;
  final int victories;
  final int defeats;
  final int winStreak;
  final int bestWinStreak;
  final double avgSessionDuration;
  final int totalDamage;
  final int totalCardsUsed;

  const SessionStats({
    this.totalSessions = 0,
    this.victories = 0,
    this.defeats = 0,
    this.winStreak = 0,
    this.bestWinStreak = 0,
    this.avgSessionDuration = 0.0,
    this.totalDamage = 0,
    this.totalCardsUsed = 0,
  });

  double get winRate =>
      totalSessions > 0 ? victories / totalSessions : 0.0;

  SessionStats copyWith({
    int? totalSessions,
    int? victories,
    int? defeats,
    int? winStreak,
    int? bestWinStreak,
    double? avgSessionDuration,
    int? totalDamage,
    int? totalCardsUsed,
  }) {
    return SessionStats(
      totalSessions: totalSessions ?? this.totalSessions,
      victories: victories ?? this.victories,
      defeats: defeats ?? this.defeats,
      winStreak: winStreak ?? this.winStreak,
      bestWinStreak: bestWinStreak ?? this.bestWinStreak,
      avgSessionDuration: avgSessionDuration ?? this.avgSessionDuration,
      totalDamage: totalDamage ?? this.totalDamage,
      totalCardsUsed: totalCardsUsed ?? this.totalCardsUsed,
    );
  }
}

/// 세션 데이터
class SessionData {
  final String sessionId;
  final DateTime startTime;
  final int duration; // seconds
  final SessionResult result;
  final int damageDealt;
  final int damageReceived;
  final int cardsUsed;
  final int elixirGenerated;
  final int trophiesWon;
  final int trophiesLost;

  const SessionData({
    required this.sessionId,
    required this.startTime,
    required this.duration,
    required this.result,
    this.damageDealt = 0,
    this.damageReceived = 0,
    this.cardsUsed = 0,
    this.elixirGenerated = 0,
    this.trophiesWon = 0,
    this.trophiesLost = 0,
  });
}

/// 세션 루프 매니저
class SessionLoopManager extends ChangeNotifier {
  // 세션 설정
  static const int _sessionDurationSeconds = 180; // 3분
  static const int _maxElixir = 10;
  static const double _elixirRegenRate = 2.8; // 2.8초당 +1

  // 현재 세션 상태
  bool _isInSession = false;
  int _sessionTimeRemaining = _sessionDurationSeconds;
  int _currentElixir = 4;
  int _playerHealth = 100;
  int _enemyHealth = 100;
  Timer? _sessionTimer;
  Timer? _elixirTimer;

  // 통계
  SessionStats _stats = const SessionStats();
  final List<SessionData> _recentSessions = [];

  // 콜백
  VoidCallback? onSessionStart;
  VoidCallback? onSessionEnd;
  Function(int)? onElixirChange;
  Function(int)? onTimeUpdate;

  // Getters
  bool get isInSession => _isInSession;
  int get sessionTimeRemaining => _sessionTimeRemaining;
  int get currentElixir => _currentElixir;
  int get maxElixir => _maxElixir;
  int get playerHealth => _playerHealth;
  int get enemyHealth => _enemyHealth;
  SessionStats get stats => _stats;
  List<SessionData> get recentSessions => List.unmodifiable(_recentSessions);

  /// 세션 시작
  void startSession() {
    if (_isInSession) return;

    _isInSession = true;
    _sessionTimeRemaining = _sessionDurationSeconds;
    _currentElixir = 4;
    _playerHealth = 100;
    _enemyHealth = 100;

    // 엘릭서 타이머 시작
    _elixirTimer = Timer.periodic(
      Duration(milliseconds: (_elixirRegenRate * 1000).toInt()),
      (_) => _regenerateElixir(),
    );

    // 세션 타이머 시작
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionTimeRemaining--;
      onTimeUpdate?.call(_sessionTimeRemaining);

      if (_sessionTimeRemaining <= 0) {
        endSession(SessionResult.timeout);
      }
    });

    notifyListeners();
    onSessionStart?.call();
  }

  /// 엘릭서 재생
  void _regenerateElixir() {
    if (_currentElixir < _maxElixir) {
      _currentElixir++;
      onElixirChange?.call(_currentElixir);
      notifyListeners();
    }
  }

  /// 카드 사용
  bool useCard(int elixirCost, int damage) {
    if (!_isInSession) return false;
    if (_currentElixir < elixirCost) return false;

    _currentElixir -= elixirCost;
    _enemyHealth = (_enemyHealth - damage).clamp(0, 100);

    onElixirChange?.call(_currentElixir);
    notifyListeners();

    // 적 반격 (시뮬레이션)
    _enemyCounterAttack();

    // 승리 체크
    if (_enemyHealth <= 0) {
      endSession(SessionResult.victory);
    }

    return true;
  }

  /// 적 반격
  void _enemyCounterAttack() {
    final damage = (20 + (DateTime.now().millisecond % 30)).clamp(10, 50);
    _playerHealth = (_playerHealth - damage).clamp(0, 100);

    if (_playerHealth <= 0) {
      endSession(SessionResult.defeat);
    }
  }

  /// 세션 종료
  void endSession(SessionResult result) {
    if (!_isInSession) return;

    _sessionTimer?.cancel();
    _elixirTimer?.cancel();

    final sessionData = SessionData(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      duration: _sessionDurationSeconds - _sessionTimeRemaining,
      result: result,
    );

    _recentSessions.insert(0, sessionData);
    if (_recentSessions.length > 10) {
      _recentSessions.removeLast();
    }

    // 통계 업데이트
    _updateStats(result, sessionData);

    _isInSession = false;
    notifyListeners();
    onSessionEnd?.call();
  }

  /// 통계 업데이트
  void _updateStats(SessionResult result, SessionData session) {
    int newVictories = _stats.victories;
    int newDefeats = _stats.defeats;
    int newWinStreak = _stats.winStreak;
    int newBestWinStreak = _stats.bestWinStreak;

    if (result == SessionResult.victory) {
      newVictories++;
      newWinStreak++;
      if (newWinStreak > newBestWinStreak) {
        newBestWinStreak = newWinStreak;
      }
    } else {
      newDefeats++;
      newWinStreak = 0;
    }

    // 평균 세션 시간 업데이트
    final totalDuration = (_stats.avgSessionDuration * _stats.totalSessions) + session.duration;
    final newAvgDuration = totalDuration / (_stats.totalSessions + 1);

    _stats = SessionStats(
      totalSessions: _stats.totalSessions + 1,
      victories: newVictories,
      defeats: newDefeats,
      winStreak: newWinStreak,
      bestWinStreak: newBestWinStreak,
      avgSessionDuration: newAvgDuration,
      totalDamage: _stats.totalDamage + session.damageDealt,
      totalCardsUsed: _stats.totalCardsUsed + session.cardsUsed,
    );
  }

  /// "한 번 더" 버튼 클릭 (Supercell 스타일 중독성 루프)
  bool canPlayAgain() {
    // 항상 다시 플레이 가능
    return true;
  }

  /// 다음 세션 추천 (Supercell 스타일)
  String getNextSessionRecommendation() {
    if (_stats.winStreak >= 3) {
      return '🔥 ${_stats.winStreak}연승 중! 기록을 깨보세요!';
    } else if (_stats.winStreak == 0) {
      return '💪 다음 세션에서 승리하세요!';
    } else if (_recentSessions.isNotEmpty) {
      final lastResult = _recentSessions.first.result;
      if (lastResult == SessionResult.defeat) {
        return '🎯 복수전! 이번엔 이기자!';
      }
    }
    return '⚡ 즉시 배틀 시작! (3분)';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _elixirTimer?.cancel();
    super.dispose();
  }
}

/// 세션 결과 화면
class SessionResultScreen extends StatelessWidget {
  final SessionResult result;
  final int trophiesWon;
  final int trophiesLost;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturnHome;

  const SessionResultScreen({
    super.key,
    required this.result,
    this.trophiesWon = 0,
    this.trophiesLost = 0,
    required this.onPlayAgain,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    final isVictory = result == SessionResult.victory;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isVictory
              ? [
                  const Color(0xFFFFD700),
                  const Color(0xFFFF6F00),
                  const Color(0xFF311B92),
                ]
              : [
                  const Color(0xFF37474F),
                  const Color(0xFF263238),
                  const Color(0xFF000000),
                ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 결과 아이콘
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isVictory
                          ? [
                              Colors.amber.withValues(alpha: 0.8),
                              Colors.orange.withValues(alpha: 0.6),
                            ]
                          : [
                              Colors.grey.withValues(alpha: 0.8),
                              Colors.black.withValues(alpha: 0.6),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isVictory
                            ? Colors.amber.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isVictory ? Icons.emoji_events : Icons.close,
                    size: 64,
                    color: isVictory ? Colors.white : Colors.white.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 32),

                // 결과 텍스트
                Text(
                  isVictory ? '승리!' : '패배',
                  style: const TextStyle(
                    fontSize: 48,
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

                const SizedBox(height: 16),

                // 메시지
                Text(
                  isVictory
                      ? '콜로니를 성공적으로 방어했습니다!'
                      : '다음에 다시 도전하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 24),

                // 트로피 변화
                if (trophiesWon > 0 || trophiesLost > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isVictory
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isVictory ? Colors.amber : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVictory ? Icons.trending_up : Icons.trending_down,
                          color: isVictory ? Colors.amber : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isVictory ? '+$trophiesWon 트로피' : '-$trophiesLost 트로피',
                          style: TextStyle(
                            color: isVictory ? Colors.amber : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 48),

                // "한 번 더" 버튼 (Supercell 스타일 중독성 루프)
                FilledButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.replay),
                  label: const Text('한 번 더'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 56),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: onReturnHome,
                  icon: const Icon(Icons.home),
                  label: const Text('홈으로'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
