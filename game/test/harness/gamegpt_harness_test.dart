library;

/// Tests for GameGPT Production Harness
/// Tests dual collaboration, layered approach, code decoupling, and redundancy detection

import 'package:flutter_test/flutter_test.dart';
import 'package:game/harness/game_production_harness.dart';
import 'package:game/harness/genre_templates.dart' show GameGenre, GenreTemplates, PhasePriority;
import 'package:game/harness/task_lexicon.dart';
import 'package:game/harness/code_lexicon.dart';
import 'package:game/harness/hallucination_detector.dart';

void main() {
  group('GameGPT - Phase 1: Planning', () {
    test('GG-001: Genre classification from description', () {
      // Session battle game
      final sessionBattle = GenreTemplates.classifyDescription(
        'A fast-paced card battle game with elixir system and real-time multiplayer',
      );
      expect(sessionBattle, GameGenre.sessionBattle);

      // Strategy game
      final strategy = GenreTemplates.classifyDescription(
        'Build your colony with resource management and building construction',
      );
      expect(strategy, GameGenre.strategy);

      // Action game
      final action = GenreTemplates.classifyDescription(
        'Fast combat with intense shooting and platforming action',
      );
      expect(action, GameGenre.action);
    });

    test('GG-002: Template retrieval by genre', () {
      final template = GenreTemplates.getTemplate(GameGenre.sessionBattle);

      expect(template, isNotNull);
      expect(template?.genre, GameGenre.sessionBattle);
      expect(template?.coreMechanics, contains('elixir'));
      expect(template?.coreMechanics, contains('cards'));
      expect(template?.coreMechanics, contains('timer'));
    });

    test('GG-003: Phase priorities for execution order', () {
      final template = GenreTemplates.getTemplate(GameGenre.sessionBattle);

      // Critical phases should come first
      final criticalPhases = template?.phases
          .where((p) => p.priority == PhasePriority.critical)
          .toList();

      expect(criticalPhases, isNotEmpty);
      expect(criticalPhases?.first.name, 'Session Timer');
    });
  });

  group('GameGPT - Phase 2: Task Classification', () {
    test('GG-004: Task type classification from keywords', () {
      final elixirTask = TaskKeywords.classify('Implement elixir generation system');
      expect(elixirTask, GameTaskType.currency);

      final uiTask = TaskKeywords.classify('Create battle screen interface');
      expect(uiTask, GameTaskType.uiScreen);

      final aiTask = TaskKeywords.classify('Implement enemy behavior AI');
      expect(aiTask, GameTaskType.aiSystem);
    });

    test('GG-005: Required arguments for task types', () {
      final template = TaskTemplates.getTemplate(GameTaskType.uiScreen);
      expect(template, isNotNull);

      final requiredArgs = TaskTemplates.getRequiredArguments(GameTaskType.uiScreen);
      expect(requiredArgs, isNotEmpty);
      expect(requiredArgs.any((arg) => arg.name == 'screen_name'), true);
    });

    test('GG-006: Redundancy detection between tasks', () {
      final tasks = [
        'Implement player movement system',
        'Create player character movement',
        'Add combat mechanics',
        'Implement fighting combat',
      ];

      final redundant = RedundancyDetector.findRedundantTasks(tasks);

      expect(redundant, isNotEmpty);
      // Should find at least one redundant pair
      expect(redundant.length, greaterThan(0));
    });

    test('GG-007: Redundancy similarity calculation', () {
      // These should be detected as redundant
      const task1 = 'Implement player movement';
      const task2 = 'Create player movement';

      expect(RedundancyDetector.areRedundant(task1, task2), true);

      // These should NOT be redundant
      const task3 = 'Implement player movement';
      const task4 = 'Add combat system';

      expect(RedundancyDetector.areRedundant(task3, task4), false);
    });
  });

  group('GameGPT - Phase 3: Code Generation', () {
    test('GG-008: Code snippet retrieval by category', () {
      final snippets = GameCodeLexicon.getByCategory('session_battle');

      expect(snippets, isNotEmpty);
      expect(snippets.any((s) => s.id == 'elixir_system'), true);
      expect(snippets.any((s) => s.id == 'battle_card'), true);
    });

    test('GG-009: Code snippet search functionality', () {
      final results = GameCodeLexicon.search('timer');

      expect(results, isNotEmpty);
      expect(results.any((s) => s.tags.contains('timer')), true);
    });

    test('GG-010: Code snippet retrieval by ID', () {
      final snippet = GameCodeLexicon.getById('elixir_system');

      expect(snippet, isNotNull);
      expect(snippet?.name, 'Elixir System');
      expect(snippet?.category, 'session_battle');
    });
  });

  group('GameGPT - Hallucination Detection', () {
    test('GG-011: Detect impossible features', () {
      const text = 'Implement impossible instant loading';
      final warnings = HallucinationDetector.detect(text);

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.type == HallucinationType.impossibleFeature), true);
    });

    test('GG-012: Detect unrealistic requirements', () {
      const text = 'Create system with zero latency and no memory';
      final warnings = HallucinationDetector.detect(text);

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.type == HallucinationType.unrealisticRequirement), true);
    });

    test('GG-013: Detect placeholder code', () {
      const code = '''
class GameSystem {
  void update() {
    // TODO: implement magic_function
    throw UnimplementedError();
  }
}
''';

      final warnings = HallucinationDetector.detect(code);
      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.type == HallucinationType.placeholder), true);
    });

    test('GG-014: Validate realistic requirements', () {
      final realistic = {
        'time_estimate': 80,
        'memory': 512,
        'quality': 'good',
      };

      expect(HallucinationDetector.areRequirementsRealistic(realistic), true);
    });

    test('GG-015: Reject unrealistic requirements', () {
      final unrealistic = {
        'time_estimate': -10, // Negative time!
        'quality': 'perfect',
      };

      expect(HallucinationDetector.areRequirementsRealistic(unrealistic), false);
    });
  });

  group('GameGPT - Hallucination Validator', () {
    test('GG-016: Validate generated task', () {
      final validator = HallucinationValidator();

      final validTask = GeneratedTask(
        id: 'task_1',
        name: 'Player Movement',
        description: 'Implement WASD movement for player character',
        requirements: {'time_estimate': 4},
      );

      final result = validator.validateTask(validTask);
      expect(result.isValid, true);
    });

    test('GG-017: Reject hallucinated task', () {
      final validator = HallucinationValidator();

      final hallucinatedTask = GeneratedTask(
        id: 'task_1',
        name: 'Magic System',
        description: 'Implement impossible instant feature',
        requirements: {'time': '0 minutes'},
      );

      final result = validator.validateTask(hallucinatedTask);
      expect(result.isRejected, true);
    });

    test('GG-018: Validate code snippet', () {
      final validator = HallucinationValidator();

      const goodCode = '''
class ElixirSystem {
  int elixir = 4;
  void regenerate() {
    if (elixir < 10) elixir++;
  }
}
''';

      final result = validator.validateCode(goodCode);
      expect(result.isValid, true);
    });

    test('GG-019: Reject hallucinated code', () {
      final validator = HallucinationValidator();

      const badCode = '''
class MagicSystem {
  void auto_solve() {
    // TODO: implement magic
  }
}
''';

      final result = validator.validateCode(badCode);
      expect(result.needsReview || result.isRejected, true);
    });

    test('GG-020: Track validation statistics', () {
      final validator = HallucinationValidator();

      // Validate multiple tasks
      validator.validateTask(GeneratedTask(
        id: 'task_1',
        name: 'Good Task',
        description: 'Valid task description',
      ));

      validator.validateTask(GeneratedTask(
        id: 'task_2',
        name: 'Bad Task',
        description: 'Implement impossible feature',
      ));

      expect(validator.validatedCount, 2);
      expect(validator.rejectedCount, 1);
      expect(validator.rejectionRate, greaterThan(0));
    });
  });

  group('GameGPT - Integration Tests', () {
    testWidgets('GG-021: Full pipeline execution', (tester) async {
      final harness = GameProductionHarness();

      // Run pipeline (simplified for test)
      expect(harness.isRunning, false);

      // Note: Full pipeline execution is async and would require
      // mocking of various components. This is a placeholder test.
    });

    test('GG-022: Genre template completeness', () {
      // All genres should have templates
      for (final genre in GameGenre.values) {
        final template = GenreTemplates.getTemplate(genre);
        expect(template, isNotNull, reason: '$genre should have a template');
        expect(template?.phases, isNotEmpty, reason: '$genre should have phases');
        expect(template?.coreMechanics, isNotEmpty, reason: '$genre should have core mechanics');
      }
    });

    test('GG-023: Code lexicon coverage', () {
      // All important categories should have snippets
      final categories = ['gameplay', 'ui', 'session_battle', 'persistence'];

      for (final category in categories) {
        final snippets = GameCodeLexicon.getByCategory(category);
        expect(snippets, isNotEmpty, reason: '$category should have code snippets');
      }
    });
  });

  group('GameGPT - Redundancy Elimination', () {
    test('GG-024: Detect duplicate tasks in plan', () {
      final tasks = [
        'Implement player movement',
        'Add player controller',
        'Create player movement system',  // Redundant with #1
        'Implement combat system',
        'Add combat mechanics',  // Redundant with #4
      ];

      final redundant = RedundancyDetector.findRedundantTasks(tasks);

      // Should find at least 1 redundant pair
      expect(redundant.length, greaterThanOrEqualTo(1));

      // Check similarity scores
      for (final pair in redundant) {
        expect(pair.similarity, greaterThan(0.6));
      }
    });

    test('GG-025: Merge redundant tasks', () {
      final tasks = [
        'Implement player movement',
        'Create player movement',
        'Add combat system',
      ];

      final redundant = RedundancyDetector.findRedundantTasks(tasks);

      // Should identify the redundant pair
      expect(redundant, isNotEmpty);

      // Find the non-redundant task (the one to keep)
      final redundantIndices = redundant
          .map((p) => [p.task1Index, p.task2Index])
          .expand((i) => i)
          .toSet();

      final nonRedundantCount = tasks.length - redundantIndices.length;
      expect(nonRedundantCount, greaterThan(0));
    });
  });

  group('GameGPT - Session Battle Specific', () {
    test('GG-026: Session battle template has elixir system', () {
      final template = GenreTemplates.getTemplate(GameGenre.sessionBattle);

      final elixirPhase = template?.phases
          .firstWhere(
            (p) => p.name.contains('Elixir') || p.name.contains('Resource'),
            orElse: () => throw Exception('Elixir phase not found'),
          );

      expect(elixirPhase, isNotNull);
      expect(elixirPhase!.tasks, contains('Elixir generation (1 per 2.8s)'));
    });

    test('GG-027: Session battle template has card system', () {
      final template = GenreTemplates.getTemplate(GameGenre.sessionBattle);

      final cardPhase = template?.phases
          .firstWhere(
            (p) => p.name.contains('Card'),
            orElse: () => throw Exception('Card phase not found'),
          );

      expect(cardPhase, isNotNull);
      expect(cardPhase!.tasks, contains('Card hand (4 cards)'));
    });

    test('GG-028: Session battle template has timer', () {
      final template = GenreTemplates.getTemplate(GameGenre.sessionBattle);

      final timerPhase = template?.phases
          .firstWhere(
            (p) => p.name.contains('Timer') || p.name.contains('Session'),
            orElse: () => throw Exception('Timer phase not found'),
          );

      expect(timerPhase, isNotNull);
      expect(timerPhase!.tasks, contains('Countdown timer (3 minutes)'));
    });

    test('GG-029: Elixir code snippet has correct parameters', () {
      final snippet = GameCodeLexicon.getById('elixir_system');

      expect(snippet, isNotNull);
      expect(snippet?.code, contains('int _elixir = 4'));
      expect(snippet?.code, contains('int _maxElixir = 10'));
      expect(snippet?.code, contains('2.8')); // regen rate
    });

    test('GG-030: Session timer has 3-minute duration', () {
      final snippet = GameCodeLexicon.getById('session_timer');

      expect(snippet, isNotNull);
      expect(snippet?.code, contains('180')); // 3 minutes in seconds
      expect(snippet?.code, contains('_sessionDuration'));
    });
  });
}
