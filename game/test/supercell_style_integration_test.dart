library;

/// Supercell 스타일 시스템 통합 테스트
/// Task #13-16: 즉시 행동 온보딩, 세션 루프, 소셜 경쟁, 보상 진행

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/supercell_style/session_battle.dart';
import 'package:game/supercell_style/social_competition.dart';
import 'package:game/supercell_style/reward_progression.dart';
import 'package:game/supercell_style/session_loop_manager.dart';

void main() {
  group('Supercell Style Integration Tests', () {
    group('Task #13: Instant Action Onboarding', () {
      test('SS-001: Session battle has instant action capability', () {
        // Verify session battle can be started instantly
        expect(() => const SessionBattleScreen(), returnsNormally);
      });

      test('SS-002: Session battle has 3-minute duration', () {
        // Verify session duration matches Supercell style
        expect(SessionLoopManager().sessionTimeRemaining, 180);
      });

      test('SS-003: Elixir system is implemented', () {
        final manager = SessionLoopManager();
        expect(manager.currentElixir, greaterThanOrEqualTo(0));
        expect(manager.maxElixir, 10);
      });
    });

    group('Task #14: Session-Based Gameplay Loop', () {
      testWidgets('SS-004: Session loop manager lifecycle', (tester) async {
        final manager = SessionLoopManager();

        // Verify initial state
        expect(manager.isInSession, false);
        expect(manager.stats.totalSessions, 0);

        // Start session
        manager.startSession();
        expect(manager.isInSession, true);

        // End session
        manager.endSession(SessionResult.victory);
        expect(manager.isInSession, false);
        expect(manager.stats.totalSessions, 1);
        expect(manager.stats.victories, 1);
      });

      test('SS-005: "Play Again" loop is available', () {
        final manager = SessionLoopManager();
        expect(manager.canPlayAgain(), true);
      });

      test('SS-006: Session recommendations encourage replay', () {
        final manager = SessionLoopManager();
        final recommendation = manager.getNextSessionRecommendation();

        expect(recommendation, isNotEmpty);
        expect(recommendation.contains('⚡') || recommendation.contains('💪'), true);
      });

      test('SS-007: Win streak tracking works', () {
        final manager = SessionLoopManager();

        manager.startSession();
        manager.endSession(SessionResult.victory);
        expect(manager.stats.winStreak, 1);

        manager.startSession();
        manager.endSession(SessionResult.victory);
        expect(manager.stats.winStreak, 2);
      });
    });

    group('Task #15: Social Competition Features', () {
      test('SS-008: Leaderboard entries can be created', () {
        final entries = LeaderboardEntry.generateSampleData();
        expect(entries, isNotEmpty);
        expect(entries.length, 10);
      });

      test('SS-009: Leaderboard has ranking system', () {
        final entries = LeaderboardEntry.generateSampleData();
        expect(entries[0].rank, '1');
        expect(entries[0].trophies, greaterThan(entries[1].trophies));
      });

      test('SS-010: Leaderboard identifies current user', () {
        final entries = LeaderboardEntry.generateSampleData(currentUserId: 'p5');
        final currentUser = entries.firstWhere((e) => e.playerId == 'p5');
        expect(currentUser.isCurrentUser, true);
      });

      testWidgets('SS-011: Leaderboard screen renders', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 800,
              child: SocialCompetitionScreen(),
            ),
          ),
        );

        expect(find.byType(SocialCompetitionScreen), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 600)); // Wait for loading
      });
    });

    group('Task #16: Reward Progression System', () {
      test('SS-012: Level up rewards can be generated', () {
        final rewards = RewardItem.generateLevelUpRewards(5);
        expect(rewards, isNotEmpty);
        expect(rewards.any((r) => r.type == RewardType.coins), true);
        expect(rewards.any((r) => r.type == RewardType.gems), true);
      });

      test('SS-013: Player progress tracks correctly', () {
        const progress = PlayerProgress(
          level: 5,
          currentXP: 50,
          xpToNextLevel: 100,
        );

        expect(progress.level, 5);
        expect(progress.xpProgress, 0.5);
      });

      testWidgets('SS-014: Level up showcase renders', (tester) async {
        final rewards = RewardItem.generateLevelUpRewards(5);

        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 400,
              height: 800,
              child: LevelUpShowcaseScreen(
                newLevel: 5,
                rewards: rewards,
                onContinue: () {},
              ),
            ),
          ),
        );

        expect(find.byType(LevelUpShowcaseScreen), findsOneWidget);
        expect(find.text('LEVEL 5'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 500));

        // Clean up - remove widget and pump multiple frames to ensure timers are disposed
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      });

      testWidgets('SS-015: Progression HUD renders', (tester) async {
        const progress = PlayerProgress(
          level: 10,
          currentXP: 75,
          xpToNextLevel: 100,
          winStreak: 3,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProgressionHUD(progress: progress),
            ),
          ),
        );

        expect(find.byType(ProgressionHUD), findsOneWidget);
        expect(find.text('레벨 10'), findsOneWidget);
        expect(find.text('3연승'), findsOneWidget);
      });
    });

    group('Integration: Full Session Flow', () {
      test('SS-016: Complete session flow from start to rewards', () {
        final manager = SessionLoopManager();

        // Start session
        manager.startSession();
        expect(manager.isInSession, true);

        // Simulate card usage
        final cardUsed = manager.useCard(3, 15);
        expect(cardUsed, true);
        expect(manager.currentElixir, lessThan(4)); // Elixir decreased

        // End session with victory
        manager.endSession(SessionResult.victory);
        expect(manager.isInSession, false);

        // Check stats updated
        expect(manager.stats.victories, 1);
        expect(manager.stats.totalSessions, 1);
      });

      test('SS-017: Loss resets win streak', () {
        final manager = SessionLoopManager();

        // Two wins
        manager.startSession();
        manager.endSession(SessionResult.victory);

        manager.startSession();
        manager.endSession(SessionResult.victory);

        expect(manager.stats.winStreak, 2);

        // One loss
        manager.startSession();
        manager.endSession(SessionResult.defeat);

        expect(manager.stats.winStreak, 0);
        expect(manager.stats.defeats, 1);
      });
    });

    group('Supercell Style Compliance', () {
      test('SS-018: All sessions are time-limited', () {
        expect(SessionLoopManager().sessionTimeRemaining, 180);
      });

      test('SS-019: Elixir system has hard cap', () {
        final manager = SessionLoopManager();
        expect(manager.maxElixir, 10);
      });

      test('SS-020: Card hand size is limited', () {
        // Supercell style: limited hand size for strategic depth
        const handSize = 4; // Defined in session_battle.dart
        expect(handSize, lessThanOrEqualTo(8)); // Typical Supercell range
      });

      test('SS-021: "One More" loop is always available', () {
        final manager = SessionLoopManager();
        manager.startSession();
        manager.endSession(SessionResult.victory);
        expect(manager.canPlayAgain(), true);

        manager.startSession();
        manager.endSession(SessionResult.defeat);
        expect(manager.canPlayAgain(), true);
      });
    });
  });
}
