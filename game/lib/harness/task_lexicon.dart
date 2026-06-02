/// Task classification lexicon for GameGPT framework
/// Based on Section 2.4: Game Development Task Classification
/// Reference: https://arxiv.org/abs/2310.08067
///
/// This in-house lexicon provides task type definitions and templates
/// to improve classification accuracy and reduce hallucination.

library;

// -----------------------------------------------------------------------------
// Task Type Definitions
// -----------------------------------------------------------------------------

/// Task types for game development
enum GameTaskType {
  // Core Systems
  gameplayMechanic,
  physicsSystem,
  inputSystem,
  cameraSystem,

  // Game Logic
  aiSystem,
  pathfinding,
  stateMachine,
  eventSystem,

  // Data & Persistence
  dataModel,
  saveSystem,
  loadSystem,
  database,

  // UI/UX
  uiScreen,
  uiWidget,
  hud,
  menu,

  // Audio/Visual
  audioSystem,
  soundEffect,
  music,
  visualEffect,
  animation,

  // Network
  networkSystem,
  multiplayer,
  matchmaking,
  leaderboards,

  // Progression
  progressionSystem,
  achievement,
  quest,
  unlockable,

  // Economy
  currency,
  shop,
  inventory,
  trading,

  // Content
  levelDesign,
  characterDesign,
  itemDesign,
  narrative,
}

// -----------------------------------------------------------------------------
// Task Type Lexicon (Keywords)
// -----------------------------------------------------------------------------

/// Keywords for identifying task types
class TaskKeywords {
  static const Map<GameTaskType, List<String>> _keywords = {
    // Core Systems
    GameTaskType.gameplayMechanic: [
      'gameplay',
      'mechanic',
      'system',
      'core',
      'fundamental',
      'game loop',
    ],
    GameTaskType.physicsSystem: [
      'physics',
      'collision',
      'gravity',
      'rigidbody',
      'velocity',
      'force',
    ],
    GameTaskType.inputSystem: [
      'input',
      'controller',
      'touch',
      'keyboard',
      'gamepad',
      'gesture',
    ],
    GameTaskType.cameraSystem: [
      'camera',
      'viewport',
      'follow',
      'pan',
      'zoom',
      'perspective',
    ],

    // Game Logic
    GameTaskType.aiSystem: [
      'ai',
      'artificial intelligence',
      'bot',
      'npc',
      'decision making',
      'behavior',
    ],
    GameTaskType.pathfinding: [
      'pathfinding',
      'navigation',
      'a*',
      'waypoint',
      'routing',
      'path',
    ],
    GameTaskType.stateMachine: [
      'state machine',
      'state',
      'transition',
      'fsm',
      'behavior state',
    ],
    GameTaskType.eventSystem: [
      'event',
      'trigger',
      'callback',
      'observer',
      'messaging',
    ],

    // Data & Persistence
    GameTaskType.dataModel: [
      'model',
      'class',
      'struct',
      'data',
      'entity',
      'object',
    ],
    GameTaskType.saveSystem: [
      'save',
      'saving',
      'serialize',
      'write',
      'persist',
    ],
    GameTaskType.loadSystem: [
      'load',
      'loading',
      'deserialize',
      'read',
      'restore',
    ],
    GameTaskType.database: [
      'database',
      'storage',
      'query',
      'index',
      'table',
    ],

    // UI/UX
    GameTaskType.uiScreen: [
      'screen',
      'page',
      'view',
      'interface',
      'display',
    ],
    GameTaskType.uiWidget: [
      'widget',
      'component',
      'element',
      'control',
      'button',
      'slider',
    ],
    GameTaskType.hud: [
      'hud',
      'heads-up display',
      'overlay',
      'status bar',
      'health bar',
      'minimap',
    ],
    GameTaskType.menu: [
      'menu',
      'pause menu',
      'settings',
      'options',
      'main menu',
    ],

    // Audio/Visual
    GameTaskType.audioSystem: [
      'audio',
      'sound system',
      'audio engine',
      'mixer',
      'dsp',
    ],
    GameTaskType.soundEffect: [
      'sfx',
      'sound effect',
      'footstep',
      'explosion',
      'impact',
    ],
    GameTaskType.music: [
      'music',
      'soundtrack',
      'bgm',
      'background music',
      'ambient',
    ],
    GameTaskType.visualEffect: [
      'vfx',
      'visual effect',
      'particle',
      'shader',
      'explosion',
      'trail',
    ],
    GameTaskType.animation: [
      'animation',
      'anim',
      'sprite',
      'skeletal',
      'tween',
      'keyframe',
    ],

    // Network
    GameTaskType.networkSystem: [
      'network',
      'networking',
      'connection',
      'protocol',
      'socket',
    ],
    GameTaskType.multiplayer: [
      'multiplayer',
      'coop',
      'competitive',
      'sync',
      'replication',
    ],
    GameTaskType.matchmaking: [
      'matchmaking',
      'match',
      'queue',
      'lobby',
      'ranking',
    ],
    GameTaskType.leaderboards: [
      'leaderboard',
      'ranking',
      'score',
      'high score',
      'competition',
    ],

    // Progression
    GameTaskType.progressionSystem: [
      'progression',
      'leveling',
      'xp',
      'experience',
      'advance',
      'unlock',
    ],
    GameTaskType.achievement: [
      'achievement',
      'trophy',
      'accomplishment',
      'badge',
      'milestone',
    ],
    GameTaskType.quest: [
      'quest',
      'mission',
      'task',
      'objective',
      'goal',
    ],
    GameTaskType.unlockable: [
      'unlock',
      'unlockable',
      'reward',
      'grant',
      'access',
    ],

    // Economy
    GameTaskType.currency: [
      'currency',
      'money',
      'gold',
      'coin',
      'elixir',
      'gem',
      'cash',
    ],
    GameTaskType.shop: [
      'shop',
      'store',
      'market',
      'purchase',
      'buy',
      'commerce',
    ],
    GameTaskType.inventory: [
      'inventory',
      'backpack',
      'bag',
      'item',
      'equipment',
    ],
    GameTaskType.trading: [
      'trade',
      'exchange',
      'barter',
      'marketplace',
      'auction',
    ],

    // Content
    GameTaskType.levelDesign: [
      'level',
      'stage',
      'map',
      'area',
      'zone',
      'world',
    ],
    GameTaskType.characterDesign: [
      'character',
      'hero',
      'unit',
      'avatar',
      'player',
    ],
    GameTaskType.itemDesign: [
      'item',
      'weapon',
      'armor',
      'equipment',
      'prop',
    ],
    GameTaskType.narrative: [
      'story',
      'narrative',
      'dialogue',
      'plot',
      'cutscene',
    ],
  };

  /// Get keywords for a task type
  static List<String> getKeywords(GameTaskType type) {
    return _keywords[type] ?? [];
  }

  /// Find best matching task type from description
  static GameTaskType? classify(String description) {
    final lowerDesc = description.toLowerCase();
    final scores = <GameTaskType, int>{};

    for (final entry in _keywords.entries) {
      final matches = entry.value
          .where((keyword) => lowerDesc.contains(keyword))
          .length;
      if (matches > 0) {
        scores[entry.key] = matches;
      }
    }

    if (scores.isEmpty) return null;

    // Return type with highest score
    final bestEntry = scores.entries.reduce((a, b) =>
        a.value > b.value ? a : b);
    return bestEntry.key;
  }
}

// -----------------------------------------------------------------------------
// Task Argument Templates
// -----------------------------------------------------------------------------

/// Templates for extracting task arguments
class TaskTemplates {
  static const Map<GameTaskType, TaskTemplate> _templates = {
    // Core Systems
    GameTaskType.gameplayMechanic: TaskTemplate(
      name: 'gameplay_mechanic',
      arguments: [
        TemplateArgument(name: 'mechanic_name', type: String, required: true),
        TemplateArgument(name: 'complexity', type: int, required: false, defaultValue: 1),
        TemplateArgument(name: 'dependencies', type: List, required: false, defaultValue: []),
      ],
    ),
    GameTaskType.physicsSystem: TaskTemplate(
      name: 'physics_system',
      arguments: [
        TemplateArgument(name: 'gravity', type: double, required: false, defaultValue: 9.8),
        TemplateArgument(name: 'collision_layers', type: int, required: false, defaultValue: 1),
      ],
    ),
    GameTaskType.inputSystem: TaskTemplate(
      name: 'input_system',
      arguments: [
        TemplateArgument(name: 'input_type', type: String, required: true),
        TemplateArgument(name: 'binding', type: Map, required: false, defaultValue: {}),
      ],
    ),

    // UI
    GameTaskType.uiScreen: TaskTemplate(
      name: 'ui_screen',
      arguments: [
        TemplateArgument(name: 'screen_name', type: String, required: true),
        TemplateArgument(name: 'layout', type: String, required: false, defaultValue: 'vertical'),
        TemplateArgument(name: 'widgets', type: List, required: false, defaultValue: []),
      ],
    ),
    GameTaskType.uiWidget: TaskTemplate(
      name: 'ui_widget',
      arguments: [
        TemplateArgument(name: 'widget_type', type: String, required: true),
        TemplateArgument(name: 'properties', type: Map, required: false, defaultValue: {}),
      ],
    ),

    // Audio
    GameTaskType.soundEffect: TaskTemplate(
      name: 'sound_effect',
      arguments: [
        TemplateArgument(name: 'effect_name', type: String, required: true),
        TemplateArgument(name: 'file_path', type: String, required: true),
        TemplateArgument(name: 'volume', type: double, required: false, defaultValue: 1.0),
        TemplateArgument(name: 'loop', type: bool, required: false, defaultValue: false),
      ],
    ),
    GameTaskType.music: TaskTemplate(
      name: 'music',
      arguments: [
        TemplateArgument(name: 'track_name', type: String, required: true),
        TemplateArgument(name: 'file_path', type: String, required: true),
        TemplateArgument(name: 'fade_in', type: double, required: false, defaultValue: 0.0),
        TemplateArgument(name: 'loop', type: bool, required: false, defaultValue: true),
      ],
    ),

    // Network
    GameTaskType.matchmaking: TaskTemplate(
      name: 'matchmaking',
      arguments: [
        TemplateArgument(name: 'mode', type: String, required: true),
        TemplateArgument(name: 'min_players', type: int, required: false, defaultValue: 2),
        TemplateArgument(name: 'max_players', type: int, required: false, defaultValue: 2),
        TemplateArgument(name: 'timeout', type: int, required: false, defaultValue: 30),
      ],
    ),

    // Economy
    GameTaskType.currency: TaskTemplate(
      name: 'currency',
      arguments: [
        TemplateArgument(name: 'currency_name', type: String, required: true),
        TemplateArgument(name: 'starting_amount', type: int, required: false, defaultValue: 0),
        TemplateArgument(name: 'max_amount', type: int, required: false, defaultValue: 999999),
      ],
    ),

    // Progression
    GameTaskType.progressionSystem: TaskTemplate(
      name: 'progression',
      arguments: [
        TemplateArgument(name: 'xp_curve', type: String, required: false, defaultValue: 'linear'),
        TemplateArgument(name: 'max_level', type: int, required: false, defaultValue: 100),
        TemplateArgument(name: 'rewards', type: Map, required: false, defaultValue: {}),
      ],
    ),
  };

  /// Get template for a task type
  static TaskTemplate? getTemplate(GameTaskType type) {
    return _templates[type];
  }

  /// Get all required arguments for a task type
  static List<TemplateArgument> getRequiredArguments(GameTaskType type) {
    return _templates[type]?.arguments
        .where((arg) => arg.required)
        .toList() ?? [];
  }
}

// -----------------------------------------------------------------------------
// Template Classes
// -----------------------------------------------------------------------------

/// Task template with argument definitions
class TaskTemplate {
  final String name;
  final List<TemplateArgument> arguments;

  const TaskTemplate({
    required this.name,
    required this.arguments,
  });
}

/// Template argument definition
class TemplateArgument {
  final String name;
  final Type type;
  final bool required;
  final dynamic defaultValue;

  const TemplateArgument({
    required this.name,
    required this.type,
    this.required = true,
    this.defaultValue,
  });
}

// -----------------------------------------------------------------------------
// Redundancy Detection
// -----------------------------------------------------------------------------

/// Detect redundant tasks to eliminate waste
class RedundancyDetector {
  /// Check if two task descriptions are redundant (similar)
  static bool areRedundant(String task1, String task2) {
    final words1 = _extractWords(task1);
    final words2 = _extractWords(task2);

    // Calculate Jaccard similarity
    final intersection = words1.intersection(words2);
    final union = words1.union(words2);

    if (union.isEmpty) return false;

    final similarity = intersection.length / union.length;

    // Tasks are redundant if similarity > 0.6
    return similarity > 0.6;
  }

  /// Find redundant tasks in a list
  static List<RedundancyPair> findRedundantTasks(List<String> tasks) {
    final redundant = <RedundancyPair>[];
    final checked = <String>{};

    for (int i = 0; i < tasks.length; i++) {
      for (int j = i + 1; j < tasks.length; j++) {
        final key = '${i}_$j';
        if (checked.contains(key)) continue;

        if (areRedundant(tasks[i], tasks[j])) {
          redundant.add(RedundancyPair(
            task1Index: i,
            task2Index: j,
            task1: tasks[i],
            task2: tasks[j],
            similarity: _calculateSimilarity(tasks[i], tasks[j]),
          ));
          checked.add(key);
        }
      }
    }

    return redundant;
  }

  static Set<String> _extractWords(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toSet();

    // Remove common stop words
    final stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'be',
      'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
      'would', 'should', 'could', 'may', 'might', 'must', 'shall', 'can',
      'need', 'implement', 'create', 'add', 'make', 'build', 'system',
    };

    return words.difference(stopWords);
  }

  static double _calculateSimilarity(String text1, String text2) {
    final words1 = _extractWords(text1);
    final words2 = _extractWords(text2);

    if (words1.isEmpty && words2.isEmpty) return 1.0;
    if (words1.isEmpty || words2.isEmpty) return 0.0;

    final intersection = words1.intersection(words1);
    final union = words1.union(words2);

    return union.isEmpty ? 0.0 : intersection.length / union.length;
  }
}

/// Information about redundant task pair
class RedundancyPair {
  final int task1Index;
  final int task2Index;
  final String task1;
  final String task2;
  final double similarity;

  const RedundancyPair({
    required this.task1Index,
    required this.task2Index,
    required this.task1,
    required this.task2,
    required this.similarity,
  });

  @override
  String toString() =>
      'Task $task1Index and $task2Index are ${(similarity * 100).toInt()}% similar:\n'
      '  "$task1"\n'
      '  "$task2"';
}
