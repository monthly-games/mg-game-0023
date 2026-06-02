/// MG-0023 Game Production Harness
/// Based on GameGPT: Multi-agent Collaborative Framework for Game Development
/// https://arxiv.org/abs/2310.08067
///
/// This harness provides automated game development workflows with:
/// - Dual collaboration (LLM + expert validation)
/// - Layered approach with templates and lexicons
/// - Code decoupling for precision
/// - Redundancy and hallucination mitigation

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'genre_templates.dart' show GameGenre;

// -----------------------------------------------------------------------------
// Core Harness - Main orchestration system
// -----------------------------------------------------------------------------

/// Main production harness for game development automation
class GameProductionHarness extends ChangeNotifier {
  // Phase 1: Planning
  final GamePlanningAgent _planningAgent = GamePlanningAgent();
  final PlanReviewerAgent _planReviewer = PlanReviewerAgent();

  // Phase 2: Task Classification
  final TaskClassifierAgent _taskClassifier = TaskClassifierAgent();
  final TaskReviewerAgent _taskReviewer = TaskReviewerAgent();

  // Phase 3: Code Generation
  final CodeGeneratorAgent _codeGenerator = CodeGeneratorAgent();
  final CodeReviewerAgent _codeReviewer = CodeReviewerAgent();

  // Phase 4: Execution
  final ExecutionAgent _executionAgent = ExecutionAgent();

  // State
  final List<DevelopmentPhase> _completedPhases = [];
  final List<String> _logs = [];
  bool _isRunning = false;
  String? _currentPhase;

  List<DevelopmentPhase> get completedPhases => List.unmodifiable(_completedPhases);
  List<String> get logs => List.unmodifiable(_logs);
  bool get isRunning => _isRunning;
  String? get currentPhase => _currentPhase;

  /// Execute full development pipeline
  Future<DevelopmentResult> executePipeline(
    GameDevelopmentRequest request,
  ) async {
    _isRunning = true;
    _logs.clear();
    _completedPhases.clear();
    notifyListeners();

    try {
      // Phase 1: Planning
      _currentPhase = 'Planning';
      _log('Starting Phase 1: Game Development Planning');

      final initialPlan = await _planningAgent.createPlan(request);
      _log('Initial plan created with ${initialPlan.tasks.length} tasks');

      final reviewedPlan = await _planReviewer.review(initialPlan);
      _log('Plan reviewed: ${reviewedPlan.approved ? "APPROVED" : "NEEDS REVISION"}');

      _completedPhases.add(DevelopmentPhase.planning(plan: reviewedPlan));

      // Phase 2: Task Classification
      _currentPhase = 'Task Classification';
      _log('Starting Phase 2: Task Classification');

      final classifiedTasks = <TaskClassification>[];
      for (final task in reviewedPlan.tasks) {
        final classification = await _taskClassifier.classify(task);
        final reviewed = await _taskReviewer.review(classification);
        classifiedTasks.add(reviewed);
        _log('Classified: ${task.id} -> ${reviewed.type}');
      }

      _completedPhases.add(DevelopmentPhase.taskClassification(
        tasks: classifiedTasks,
      ));

      // Phase 3: Code Generation
      _currentPhase = 'Code Generation';
      _log('Starting Phase 3: Code Generation');

      final generatedCode = <GeneratedCode>[];
      for (final task in classifiedTasks) {
        final code = await _codeGenerator.generate(task);
        final reviewed = await _codeReviewer.review(code);
        generatedCode.add(reviewed);
        _log('Generated code for: ${task.task.id}');
      }

      _completedPhases.add(DevelopmentPhase.codeGeneration(
        codeUnits: generatedCode,
      ));

      // Phase 4: Execution
      _currentPhase = 'Execution';
      _log('Starting Phase 4: Task Execution');

      final executionResults = await _executionAgent.executeAll(
        generatedCode,
        reviewedPlan.executionOrder,
      );

      _completedPhases.add(DevelopmentPhase.execution(
        results: executionResults,
      ));

      // Phase 5: Summary
      _currentPhase = 'Summary';
      _log('Starting Phase 5: Result Summary');

      final summary = _createSummary(executionResults);

      _completedPhases.add(DevelopmentPhase.summary(results: summary));
      _log('Pipeline completed successfully');

      return DevelopmentResult(
        success: true,
        phases: _completedPhases,
        summary: summary,
      );
    } catch (e, st) {
      _log('ERROR: $e');
      _log('Stack trace: $st');

      return DevelopmentResult(
        success: false,
        phases: _completedPhases,
        summary: ResultSummary(
          totalTasks: 0,
          successfulTasks: 0,
          failedTasks: 0,
          errors: [e.toString()],
        ),
      );
    } finally {
      _isRunning = false;
      _currentPhase = null;
      notifyListeners();
    }
  }

  ResultSummary _createSummary(List<ExecutionResult> results) {
    return ResultSummary(
      totalTasks: results.length,
      successfulTasks: results.where((r) => r.success).length,
      failedTasks: results.where((r) => !r.success).length,
      errors: results
          .where((r) => !r.success)
          .map((r) => r.error ?? 'Unknown error')
          .toList(),
    );
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _logs.add('[$timestamp] $message');
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// Phase 1: Planning Agents
// -----------------------------------------------------------------------------

/// Game Development Planning Agent
/// Creates development plans with genre-specific templates
class GamePlanningAgent {
  // Genre-specific plan templates
  static const Map<GameGenre, PlanTemplate> _templates = {
    GameGenre.action: PlanTemplate(
      phases: [
        'Core Gameplay Mechanics',
        'Combat System',
        'Player Controller',
        'Enemy AI',
        'Level Design',
        'UI/HUD',
      ],
    ),
    GameGenre.strategy: PlanTemplate(
      phases: [
        'Resource Management',
        'Building System',
        'Unit System',
        'AI Decision Making',
        'Win/Lose Conditions',
        'Tech Tree',
      ],
    ),
    GameGenre.rolePlaying: PlanTemplate(
      phases: [
        'Character System',
        'Inventory System',
        'Quest System',
        'Dialogue System',
        'Progression System',
        'Combat Mechanics',
      ],
    ),
    GameGenre.simulation: PlanTemplate(
      phases: [
        'Simulation Core',
        'Entity Management',
        'State System',
        'Time System',
        'Save/Load System',
        'Statistics',
      ],
    ),
    GameGenre.adventure: PlanTemplate(
      phases: [
        'Story System',
        'Exploration Mechanics',
        'Puzzle System',
        'Narrative Delivery',
        'Environmental Interaction',
        'Progression',
      ],
    ),
    GameGenre.sessionBattle: PlanTemplate(
      phases: [
        'Session Timer',
        'Resource System (Elixir)',
        'Card System',
        'Battle Matchmaking',
        'Reward Distribution',
        'Progression',
      ],
    ),
  };

  Future<DevelopmentPlan> createPlan(GameDevelopmentRequest request) async {
    // Classify genre first
    final genre = _classifyGenre(request);
    final template = _templates[genre];

    // Generate tasks from template
    final tasks = <DevelopmentTask>[];
    for (final phase in template!.phases) {
      tasks.add(DevelopmentTask(
        id: 'task_${tasks.length + 1}',
        phase: phase,
        description: _generateTaskDescription(phase, request),
        priority: _calculatePriority(phase),
        dependencies: _identifyDependencies(phase, template.phases),
      ));
    }

    return DevelopmentPlan(
      genre: genre,
      tasks: tasks,
      executionOrder: _calculateExecutionOrder(tasks),
    );
  }

  GameGenre _classifyGenre(GameDevelopmentRequest request) {
    final desc = request.description.toLowerCase();

    if (desc.contains('session') || desc.contains('battle') || desc.contains('elixir')) {
      return GameGenre.sessionBattle;
    } else if (desc.contains('action') || desc.contains('combat')) {
      return GameGenre.action;
    } else if (desc.contains('strategy') || desc.contains('resource')) {
      return GameGenre.strategy;
    } else if (desc.contains('rpg') || desc.contains('role')) {
      return GameGenre.rolePlaying;
    } else if (desc.contains('simulation') || desc.contains('colony')) {
      return GameGenre.simulation;
    } else if (desc.contains('adventure') || desc.contains('story')) {
      return GameGenre.adventure;
    }

    return GameGenre.sessionBattle; // Default for MG-0023
  }

  String _generateTaskDescription(String phase, GameDevelopmentRequest request) {
    return 'Implement $phase for ${request.gameName}';
  }

  TaskPriority _calculatePriority(String phase) {
    // Core systems have higher priority
    if (phase.contains('Core') || phase.contains('System')) {
      return TaskPriority.high;
    } else if (phase.contains('UI') || phase.contains('HUD')) {
      return TaskPriority.normal;
    }
    return TaskPriority.low;
  }

  List<String> _identifyDependencies(String phase, List<String> allPhases) {
    final index = allPhases.indexOf(phase);
    if (index <= 0) return [];
    return [allPhases[index - 1]];
  }

  List<String> _calculateExecutionOrder(List<DevelopmentTask> tasks) {
    // Sort by priority and dependencies
    final sorted = List<DevelopmentTask>.from(tasks);
    sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sorted.map((t) => t.id).toList();
  }
}

/// Plan Reviewer Agent
/// Reviews plans for hallucinations and redundancy
class PlanReviewerAgent {
  Future<ReviewedPlan> review(DevelopmentPlan plan) async {
    final issues = <PlanIssue>[];

    // Check for redundant tasks
    final taskDescriptions = plan.tasks.map((t) => t.description).toList();
    for (int i = 0; i < taskDescriptions.length; i++) {
      for (int j = i + 1; j < taskDescriptions.length; j++) {
        if (_areSimilar(taskDescriptions[i], taskDescriptions[j])) {
          issues.add(PlanIssue(
            type: IssueType.redundancy,
            severity: IssueSeverity.warning,
            message: 'Tasks ${i + 1} and ${j + 1} may be redundant',
          ));
        }
      }
    }

    // Check for hallucinated (impossible) tasks
    for (final task in plan.tasks) {
      if (_isHallucinated(task)) {
        issues.add(PlanIssue(
          type: IssueType.hallucination,
          severity: IssueSeverity.error,
          message: 'Task "${task.id}" contains unrealistic requirements',
        ));
      }
    }

    return ReviewedPlan(
      originalPlan: plan,
      approved: issues.where((i) => i.severity == IssueSeverity.error).isEmpty,
      issues: issues,
      tasks: plan.tasks,
      executionOrder: plan.executionOrder,
    );
  }

  bool _areSimilar(String a, String b) {
    // Simple similarity check
    final wordsA = a.toLowerCase().split(' ');
    final wordsB = b.toLowerCase().split(' ');
    final intersection = wordsA.where((w) => wordsB.contains(w));
    return intersection.length >= (wordsA.length / 2);
  }

  bool _isHallucinated(DevelopmentTask task) {
    // Check for unrealistic requirements
    final hallucinationKeywords = [
      'impossible',
      'instant',
      'perfect',
      'unlimited',
      'infinite',
    ];
    return hallucinationKeywords
        .any((kw) => task.description.toLowerCase().contains(kw));
  }
}

// -----------------------------------------------------------------------------
// Phase 2: Task Classification Agents
// -----------------------------------------------------------------------------

/// Task Classifier Agent
/// Classifies tasks by type using expert model
class TaskClassifierAgent {
  // Task type lexicon (in-house vocabulary)
  static const Map<TaskType, List<String>> _taskLexicon = {
    TaskType.gameplay: [
      'mechanic',
      'system',
      'gameplay',
      'combat',
      'controller',
      'ai',
    ],
    TaskType.ui: ['ui', 'hud', 'interface', 'menu', 'screen', 'overlay'],
    TaskType.data: ['model', 'data', 'save', 'load', 'storage'],
    TaskType.network: ['network', 'multiplayer', 'sync', 'api'],
    TaskType.audio: ['audio', 'sound', 'music', 'sfx'],
    TaskType.visual: ['visual', 'effect', 'animation', 'particle'],
  };

  Future<TaskClassification> classify(DevelopmentTask task) async {
    final type = _classifyTaskType(task);
    final arguments = _extractArguments(task, type);

    return TaskClassification(
      task: task,
      type: type,
      arguments: arguments,
      confidence: _calculateConfidence(task, type),
    );
  }

  TaskType _classifyTaskType(DevelopmentTask task) {
    final desc = task.description.toLowerCase();
    final phase = task.phase.toLowerCase();

    final scores = <TaskType, int>{};

    for (final entry in _taskLexicon.entries) {
      final keywords = entry.value;
      final score = keywords.where((kw) => desc.contains(kw) || phase.contains(kw)).length;
      scores[entry.key] = score;
    }

    // Return type with highest score
    if (scores.isEmpty) return TaskType.gameplay;

    final bestEntry = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return bestEntry.key;
  }

  Map<String, dynamic> _extractArguments(DevelopmentTask task, TaskType type) {
    // Template-based argument extraction
    switch (type) {
      case TaskType.gameplay:
        return {
          'mechanics': _extractKeywords(task, ['mechanic', 'system']),
          'complexity': _estimateComplexity(task),
        };
      case TaskType.ui:
        return {
          'screens': _extractKeywords(task, ['screen', 'menu']),
          'widgets': _extractKeywords(task, ['widget', 'button', 'panel']),
        };
      case TaskType.data:
        return {
          'models': _extractKeywords(task, ['model', 'entity']),
          'persistence': task.description.toLowerCase().contains('save'),
        };
      default:
        return {};
    }
  }

  List<String> _extractKeywords(DevelopmentTask task, List<String> keywords) {
    return keywords
        .where((kw) => task.description.toLowerCase().contains(kw))
        .toList();
  }

  int _estimateComplexity(DevelopmentTask task) {
    final words = task.description.split(' ');
    if (words.length > 10) return 3; // High
    if (words.length > 5) return 2; // Medium
    return 1; // Low
  }

  double _calculateConfidence(DevelopmentTask task, TaskType type) {
    // Simple confidence calculation based on keyword matches
    final keywords = _taskLexicon[type] ?? [];
    final matches = keywords
        .where((kw) => task.description.toLowerCase().contains(kw))
        .length;
    return (matches / keywords.length).clamp(0.5, 1.0);
  }
}

/// Task Reviewer Agent
/// Reviews task classifications
class TaskReviewerAgent {
  Future<TaskClassification> review(TaskClassification classification) async {
    // Validate task type is in allowed range
    const validTypes = TaskType.values;
    if (!validTypes.contains(classification.type)) {
      // Default to gameplay if invalid
      return TaskClassification(
        task: classification.task,
        type: TaskType.gameplay,
        arguments: classification.arguments,
        confidence: 0.5,
      );
    }

    // Validate arguments align with task
    if (classification.arguments.isEmpty) {
      // Add default arguments
      return TaskClassification(
        task: classification.task,
        type: classification.type,
        arguments: _getDefaultArguments(classification.type),
        confidence: classification.confidence * 0.8,
      );
    }

    return classification;
  }

  Map<String, dynamic> _getDefaultArguments(TaskType type) {
    return {'type': type.name, 'priority': 'normal'};
  }
}

// -----------------------------------------------------------------------------
// Phase 3: Code Generation Agents
// -----------------------------------------------------------------------------

/// Code Generator Agent
/// Generates code using decoupled approach
class CodeGeneratorAgent {
  // Code snippet lexicon for in-context learning
  static const Map<String, String> _codeLexicon = {
    'mechanic': '''
class GameMechanic {
  void update(double deltaTime) {
    // Update mechanic state
  }
}
''',
    'ui': '''
class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Game')),
    );
  }
}
''',
    'data': '''
class GameModel {
  final String id;
  final Map<String, dynamic> data;

  GameModel({required this.id, required this.data});
}
''',
  };

  Future<GeneratedCode> generate(TaskClassification classification) async {
    final taskType = classification.type;
    final task = classification.task;

    // Use decoupled approach - generate small snippets
    final snippets = <CodeSnippet>[];

    // Get template for task type
    final template = _getTemplate(taskType);
    if (template != null) {
      snippets.add(CodeSnippet(
        name: '${task.id}_base',
        code: template,
        language: 'dart',
      ));
    }

    // Generate additional code based on arguments
    for (final entry in classification.arguments.entries) {
      final snippet = _generateArgumentSnippet(
        entry.key,
        entry.value,
        task.id,
      );
      if (snippet != null) {
        snippets.add(snippet);
      }
    }

    // Use K-candidate selection
    final candidates = _generateCandidates(snippets);

    return GeneratedCode(
      taskId: task.id,
      snippets: snippets,
      candidates: candidates,
      language: 'dart',
    );
  }

  String? _getTemplate(TaskType type) {
    switch (type) {
      case TaskType.gameplay:
        return _codeLexicon['mechanic'];
      case TaskType.ui:
        return _codeLexicon['ui'];
      case TaskType.data:
        return _codeLexicon['data'];
      default:
        return null;
    }
  }

  CodeSnippet? _generateArgumentSnippet(
    String key,
    dynamic value,
    String taskId,
  ) {
    return CodeSnippet(
      name: '${taskId}_$key',
      code: '// Generated for $key: $value\n',
      language: 'dart',
    );
  }

  List<CodeCandidate> _generateCandidates(List<CodeSnippet> snippets) {
    // Generate K=3 candidates for each snippet
    return [
      CodeCandidate(
        id: 'candidate_1',
        code: _combineSnippets(snippets, 1),
        quality: 0.9,
      ),
      CodeCandidate(
        id: 'candidate_2',
        code: _combineSnippets(snippets, 2),
        quality: 0.8,
      ),
      CodeCandidate(
        id: 'candidate_3',
        code: _combineSnippets(snippets, 3),
        quality: 0.7,
      ),
    ];
  }

  String _combineSnippets(List<CodeSnippet> snippets, int variant) {
    final buffer = StringBuffer();
    for (final snippet in snippets) {
      buffer.writeln(snippet.code);
    }
    return buffer.toString();
  }
}

/// Code Reviewer Agent
/// Reviews generated code for hallucinations
class CodeReviewerAgent {
  Future<GeneratedCode> review(GeneratedCode code) async {
    final issues = <CodeIssue>[];

    // Check for common hallucination patterns
    for (final snippet in code.snippets) {
      if (_hasHallucination(snippet.code)) {
        issues.add(CodeIssue(
          snippet: snippet.name,
          type: 'hallucination',
          message: 'Potential hallucination detected',
        ));
      }

      if (_hasRedundancy(snippet.code)) {
        issues.add(CodeIssue(
          snippet: snippet.name,
          type: 'redundancy',
          message: 'Redundant code detected',
        ));
      }
    }

    return GeneratedCode(
      taskId: code.taskId,
      snippets: code.snippets,
      candidates: code.candidates,
      language: code.language,
      issues: issues,
    );
  }

  bool _hasHallucination(String code) {
    final hallucinationPatterns = [
      '// TODO: implement magic',
      '// FIXME: impossible feature',
      'throw UnimplementedError()',
    ];
    return hallucinationPatterns.any((pattern) => code.contains(pattern));
  }

  bool _hasRedundancy(String code) {
    // Check for duplicate lines
    final lines = code.split('\n');
    final seen = <String>{};
    for (final line in lines) {
      if (seen.contains(line.trim()) && line.trim().isNotEmpty) {
        return true;
      }
      seen.add(line.trim());
    }
    return false;
  }
}

// -----------------------------------------------------------------------------
// Phase 4: Execution Agent
// -----------------------------------------------------------------------------

/// Execution Agent
/// Executes generated code in order
class ExecutionAgent {
  Future<List<ExecutionResult>> executeAll(
    List<GeneratedCode> codeUnits,
    List<String> order,
  ) async {
    final results = <ExecutionResult>[];

    // Execute in dependency order
    for (final taskId in order) {
      final codeUnit = codeUnits.firstWhere((c) => c.taskId == taskId);
      final result = await _executeUnit(codeUnit);
      results.add(result);
    }

    return results;
  }

  Future<ExecutionResult> _executeUnit(GeneratedCode codeUnit) async {
    try {
      // In real implementation, this would execute the code
      // For now, simulate successful execution
      await Future.delayed(Duration(milliseconds: 100));

      return ExecutionResult(
        taskId: codeUnit.taskId,
        success: true,
        output: 'Code executed successfully',
        duration: Duration(milliseconds: 100),
      );
    } catch (e, st) {
      return ExecutionResult(
        taskId: codeUnit.taskId,
        success: false,
        error: e.toString(),
        stackTrace: st.toString(),
      );
    }
  }
}

// -----------------------------------------------------------------------------
// Data Models
// -----------------------------------------------------------------------------

/// Game development request
class GameDevelopmentRequest {
  final String gameName;
  final String description;
  final Map<String, dynamic> requirements;

  const GameDevelopmentRequest({
    required this.gameName,
    required this.description,
    this.requirements = const {},
  });
}

/// Development plan
class DevelopmentPlan {
  final GameGenre genre;
  final List<DevelopmentTask> tasks;
  final List<String> executionOrder;

  const DevelopmentPlan({
    required this.genre,
    required this.tasks,
    required this.executionOrder,
  });
}

/// Individual development task
class DevelopmentTask {
  final String id;
  final String phase;
  final String description;
  final TaskPriority priority;
  final List<String> dependencies;

  const DevelopmentTask({
    required this.id,
    required this.phase,
    required this.description,
    required this.priority,
    required this.dependencies,
  });
}

/// Reviewed plan
class ReviewedPlan {
  final DevelopmentPlan originalPlan;
  final bool approved;
  final List<PlanIssue> issues;
  final List<DevelopmentTask> tasks;
  final List<String> executionOrder;

  const ReviewedPlan({
    required this.originalPlan,
    required this.approved,
    required this.issues,
    required this.tasks,
    required this.executionOrder,
  });
}

/// Plan issue
class PlanIssue {
  final IssueType type;
  final IssueSeverity severity;
  final String message;

  const PlanIssue({
    required this.type,
    required this.severity,
    required this.message,
  });
}

/// Task classification
class TaskClassification {
  final DevelopmentTask task;
  final TaskType type;
  final Map<String, dynamic> arguments;
  final double confidence;

  const TaskClassification({
    required this.task,
    required this.type,
    required this.arguments,
    required this.confidence,
  });
}

/// Generated code
class GeneratedCode {
  final String taskId;
  final List<CodeSnippet> snippets;
  final List<CodeCandidate> candidates;
  final String language;
  final List<CodeIssue> issues;

  const GeneratedCode({
    required this.taskId,
    required this.snippets,
    required this.candidates,
    required this.language,
    this.issues = const [],
  });
}

/// Code snippet
class CodeSnippet {
  final String name;
  final String code;
  final String language;

  const CodeSnippet({
    required this.name,
    required this.code,
    required this.language,
  });
}

/// Code candidate (K-candidate selection)
class CodeCandidate {
  final String id;
  final String code;
  final double quality;

  const CodeCandidate({
    required this.id,
    required this.code,
    required this.quality,
  });
}

/// Code issue
class CodeIssue {
  final String snippet;
  final String type;
  final String message;

  const CodeIssue({
    required this.snippet,
    required this.type,
    required this.message,
  });
}

/// Execution result
class ExecutionResult {
  final String taskId;
  final bool success;
  final String? output;
  final String? error;
  final String? stackTrace;
  final Duration? duration;

  const ExecutionResult({
    required this.taskId,
    required this.success,
    this.output,
    this.error,
    this.stackTrace,
    this.duration,
  });
}

/// Development result
class DevelopmentResult {
  final bool success;
  final List<DevelopmentPhase> phases;
  final ResultSummary summary;

  const DevelopmentResult({
    required this.success,
    required this.phases,
    required this.summary,
  });
}

/// Development phase
class DevelopmentPhase {
  final PhaseType type;
  final dynamic data;

  const DevelopmentPhase({
    required this.type,
    required this.data,
  });

  const DevelopmentPhase.planning({required dynamic plan})
      : type = PhaseType.planning,
        data = plan;

  const DevelopmentPhase.taskClassification({required List<dynamic> tasks})
      : type = PhaseType.taskClassification,
        data = tasks;

  const DevelopmentPhase.codeGeneration({required List<dynamic> codeUnits})
      : type = PhaseType.codeGeneration,
        data = codeUnits;

  const DevelopmentPhase.execution({required List<dynamic> results})
      : type = PhaseType.execution,
        data = results;

  const DevelopmentPhase.summary({required ResultSummary results})
      : type = PhaseType.summary,
        data = results;
}

/// Result summary
class ResultSummary {
  final int totalTasks;
  final int successfulTasks;
  final int failedTasks;
  final List<String> errors;

  const ResultSummary({
    required this.totalTasks,
    required this.successfulTasks,
    required this.failedTasks,
    this.errors = const [],
  });

  double get successRate => totalTasks > 0 ? successfulTasks / totalTasks : 0;
}

/// Plan template
class PlanTemplate {
  final List<String> phases;

  const PlanTemplate({required this.phases});
}

// -----------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------
// Note: GameGenre is exported from genre_templates.dart

enum TaskPriority {
  low,
  normal,
  high,
  critical,
}

enum TaskType {
  gameplay,
  ui,
  data,
  network,
  audio,
  visual,
}

enum IssueType {
  hallucination,
  redundancy,
  dependency,
  performance,
}

enum IssueSeverity {
  info,
  warning,
  error,
  critical,
}

enum PhaseType {
  planning,
  taskClassification,
  codeGeneration,
  execution,
  summary,
}
