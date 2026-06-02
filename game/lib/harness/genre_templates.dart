/// Genre-specific plan templates for GameGPT framework
/// Based on Section 2.3: Game Development Planning
/// Reference: https://arxiv.org/abs/2310.08067

library;

/// Plan template for a specific game genre
class GenreTemplate {
  final GameGenre genre;
  final String description;
  final List<TemplatePhase> phases;
  final List<String> coreMechanics;
  final List<String> requiredSystems;
  final Duration estimatedDevelopmentTime;

  const GenreTemplate({
    required this.genre,
    required this.description,
    required this.phases,
    required this.coreMechanics,
    required this.requiredSystems,
    required this.estimatedDevelopmentTime,
  });
}

/// A phase in the genre template
class TemplatePhase {
  final String name;
  final String description;
  final List<String> tasks;
  final PhasePriority priority;

  const TemplatePhase({
    required this.name,
    required this.description,
    required this.tasks,
    required this.priority,
  });
}

/// Phase priority for execution ordering
enum PhasePriority {
  critical,
  high,
  normal,
  low,
}

/// Supported game genres
enum GameGenre {
  action,
  strategy,
  rolePlaying,
  simulation,
  adventure,
  sessionBattle,
  puzzle,
  sports,
}

// -----------------------------------------------------------------------------
// Genre Templates
// -----------------------------------------------------------------------------

class GenreTemplates {
  /// Action Game Template
  static const GenreTemplate action = GenreTemplate(
    genre: GameGenre.action,
    description: 'Fast-paced gameplay emphasizing reflexes and combat',
    phases: [
      TemplatePhase(
        name: 'Core Gameplay Mechanics',
        description: 'Implement fundamental player controls and physics',
        tasks: [
          'Player movement controller',
          'Input handling system',
          'Physics integration',
          'Camera system',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Combat System',
        description: 'Implement combat mechanics and damage system',
        tasks: [
          'Weapon system',
          'Damage calculation',
          'Hit detection',
          'Health system',
          'Combat animations',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Enemy AI',
        description: 'Implement enemy behavior and pathfinding',
        tasks: [
          'AI state machine',
          'Pathfinding system',
          'Enemy spawning',
          'Difficulty scaling',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Level Design',
        description: 'Create and manage game levels',
        tasks: [
          'Level editor',
          'Level loading system',
          'Checkpoint system',
          'Progression tracking',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'UI/HUD',
        description: 'Implement user interface elements',
        tasks: [
          'Health bar display',
          'Ammo counter',
          'Mini-map',
          'Pause menu',
          'Settings screen',
        ],
        priority: PhasePriority.normal,
      ),
    ],
    coreMechanics: ['player_controller', 'combat', 'physics', 'ai'],
    requiredSystems: ['input', 'physics', 'audio', 'graphics'],
    estimatedDevelopmentTime: Duration(hours: 80),
  );

  /// Strategy Game Template
  static const GenreTemplate strategy = GenreTemplate(
    genre: GameGenre.strategy,
    description: 'Tactical gameplay emphasizing resource management and planning',
    phases: [
      TemplatePhase(
        name: 'Resource Management',
        description: 'Implement resource gathering and management',
        tasks: [
          'Resource types (gold, wood, food, etc.)',
          'Resource gathering system',
          'Storage system',
          'Trade mechanics',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Building System',
        description: 'Implement construction and building management',
        tasks: [
          'Building placement',
          'Building types and functions',
          'Construction queue',
          'Upgrade system',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Unit System',
        description: 'Implement unit creation and control',
        tasks: [
          'Unit types',
          'Unit training',
          'Control groups',
          'Formation system',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'AI Decision Making',
        description: 'Implement opponent AI',
        tasks: [
          'AI strategy evaluation',
          'Build order logic',
          'Attack coordination',
          'Defensive positioning',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Win/Lose Conditions',
        description: 'Implement victory and defeat conditions',
        tasks: [
          'Victory conditions',
          'Defeat conditions',
          'Game over screen',
          'Statistics tracking',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Tech Tree',
        description: 'Implement research and upgrades',
        tasks: [
          'Research tree structure',
          'Unlock conditions',
          'Upgrade effects',
          'Tech UI',
        ],
        priority: PhasePriority.normal,
      ),
    ],
    coreMechanics: ['resource_management', 'building', 'units', 'tech_tree'],
    requiredSystems: ['ai', 'pathfinding', 'economy', 'ui'],
    estimatedDevelopmentTime: Duration(hours: 100),
  );

  /// Role-Playing Game Template
  static const GenreTemplate rolePlaying = GenreTemplate(
    genre: GameGenre.rolePlaying,
    description: 'Story-driven gameplay with character progression',
    phases: [
      TemplatePhase(
        name: 'Character System',
        description: 'Implement character creation and attributes',
        tasks: [
          'Character stats',
          'Character classes',
          'Skill system',
          'Experience and leveling',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Inventory System',
        description: 'Implement item management',
        tasks: [
          'Inventory UI',
          'Item types',
          'Equipment system',
          'Consumables',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Quest System',
        description: 'Implement mission and quest tracking',
        tasks: [
          'Quest database',
          'Quest objectives',
          'Quest tracking UI',
          'Quest rewards',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Dialogue System',
        description: 'Implement NPC conversations',
        tasks: [
          'Dialogue tree',
          'NPC interaction',
          'Branching conversations',
          'Dialogue UI',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Progression System',
        description: 'Implement character advancement',
        tasks: [
          'Skill tree',
          'Attribute points',
          'Talent system',
          'Mastery system',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Combat Mechanics',
        description: 'Implement RPG combat system',
        tasks: [
          'Turn-based or real-time combat',
          'Ability system',
          'Status effects',
          'Combat calculations',
        ],
        priority: PhasePriority.high,
      ),
    ],
    coreMechanics: ['character', 'inventory', 'quests', 'dialogue'],
    requiredSystems: ['save_load', 'dialogue', 'combat', 'progression'],
    estimatedDevelopmentTime: Duration(hours: 120),
  );

  /// Simulation Game Template
  static const GenreTemplate simulation = GenreTemplate(
    genre: GameGenre.simulation,
    description: 'Realistic simulation of real-world activities',
    phases: [
      TemplatePhase(
        name: 'Simulation Core',
        description: 'Implement core simulation loop',
        tasks: [
          'Time system',
          'Simulation tick',
          'Entity lifecycle',
          'Event system',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Entity Management',
        description: 'Manage simulation entities',
        tasks: [
          'Entity spawning',
          'Entity AI',
          'Entity relationships',
          'Entity statistics',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'State System',
        description: 'Manage simulation state',
        tasks: [
          'State serialization',
          'Save system',
          'Load system',
          'State validation',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Time System',
        description: 'Implement game time mechanics',
        tasks: [
          'Day/night cycle',
          'Season system',
          'Calendar',
          'Time acceleration',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Save/Load System',
        description: 'Implement persistent state',
        tasks: [
          'Save file format',
          'Auto-save',
          'Manual save/load',
          'Cloud sync',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Statistics',
        description: 'Track simulation metrics',
        tasks: [
          'Metric collection',
          'Statistics UI',
          'Analytics',
          'Achievements',
        ],
        priority: PhasePriority.normal,
      ),
    ],
    coreMechanics: ['simulation_loop', 'entities', 'time', 'persistence'],
    requiredSystems: ['save_load', 'ai', 'ui', 'data'],
    estimatedDevelopmentTime: Duration(hours: 90),
  );

  /// Adventure Game Template
  static const GenreTemplate adventure = GenreTemplate(
    genre: GameGenre.adventure,
    description: 'Story and exploration-focused gameplay',
    phases: [
      TemplatePhase(
        name: 'Story System',
        description: 'Implement narrative framework',
        tasks: [
          'Story database',
          'Chapter system',
          'Story progression',
          'Branching narrative',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Exploration Mechanics',
        description: 'Implement world exploration',
        tasks: [
          'Map system',
          'Discovery mechanics',
          'Fast travel',
          'Area unlocking',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Puzzle System',
        description: 'Implement puzzle mechanics',
        tasks: [
          'Puzzle types',
          'Puzzle logic',
          'Hint system',
          'Puzzle rewards',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Narrative Delivery',
        description: 'Implement story presentation',
        tasks: [
          'Cutscene system',
          'Dialogue display',
          'Narration UI',
          'Voice-over support',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Environmental Interaction',
        description: 'Implement object interaction',
        tasks: [
          'Interactive objects',
          'Item pickup system',
          'Object manipulation',
          'Context-sensitive actions',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Progression',
        description: 'Track player progress',
        tasks: [
          'Checkpoint system',
          'Story tracking',
          'Collectibles',
          'Secret discoveries',
        ],
        priority: PhasePriority.normal,
      ),
    ],
    coreMechanics: ['story', 'exploration', 'puzzles', 'interaction'],
    requiredSystems: ['dialogue', 'save_load', 'ui', 'audio'],
    estimatedDevelopmentTime: Duration(hours: 85),
  );

  /// Session Battle Game Template (Supercell Style)
  static const GenreTemplate sessionBattle = GenreTemplate(
    genre: GameGenre.sessionBattle,
    description: 'Short, intense multiplayer sessions with instant replay',
    phases: [
      TemplatePhase(
        name: 'Session Timer',
        description: 'Implement timed session mechanics',
        tasks: [
          'Countdown timer (3 minutes)',
          'Overtime system',
          'Session start/end',
          'Timer UI',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Resource System (Elixir)',
        description: 'Implement elixir-based resource system',
        tasks: [
          'Elixir generation (1 per 2.8s)',
          'Elixir capacity (max 10)',
          'Elixir display',
          'Elixir sound effects',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Card System',
        description: 'Implement card-based gameplay',
        tasks: [
          'Card hand (4 cards)',
          'Card deck management',
          'Card drawing',
          'Card elixir costs',
          'Card abilities',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Battle Matchmaking',
        description: 'Implement player matching',
        tasks: [
          'Quick match',
          'Ranked match',
          'Friend battle',
          'Trophy system',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Reward Distribution',
        description: 'Implement post-battle rewards',
        tasks: [
          'Chest system',
          'Gold rewards',
          'Trophy changes',
          'Progress bars',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Progression',
        description: 'Implement long-term progression',
        tasks: [
          'Arena tiers',
          'Card unlocking',
          'Card upgrading',
          'League promotion',
        ],
        priority: PhasePriority.high,
      ),
    ],
    coreMechanics: ['elixir', 'cards', 'timer', 'matchmaking'],
    requiredSystems: ['network', 'ui', 'progression', 'rewards'],
    estimatedDevelopmentTime: Duration(hours: 70),
  );

  /// Puzzle Game Template
  static const GenreTemplate puzzle = GenreTemplate(
    genre: GameGenre.puzzle,
    description: 'Brain-teasing puzzles with increasing difficulty',
    phases: [
      TemplatePhase(
        name: 'Core Puzzle Mechanics',
        description: 'Implement fundamental puzzle logic',
        tasks: [
          'Puzzle rules',
          'Input validation',
          'Move validation',
          'Win/lose detection',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Level System',
        description: 'Create puzzle progression',
        tasks: [
          'Level definitions',
          'Difficulty scaling',
          'Level unlocking',
          'Star rating',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Hint System',
        description: 'Implement player assistance',
        tasks: [
          'Hint logic',
          'Hint availability',
          'Hint UI',
          'Hint economy',
        ],
        priority: PhasePriority.high,
      ),
      TemplatePhase(
        name: 'Scoring',
        description: 'Track player performance',
        tasks: [
          'Score calculation',
          'Combo system',
          'High score tracking',
          'Leaderboard integration',
        ],
        priority: PhasePriority.high,
      ),
    ],
    coreMechanics: ['puzzle_logic', 'levels', 'scoring'],
    requiredSystems: ['ui', 'save_load', 'analytics'],
    estimatedDevelopmentTime: Duration(hours: 50),
  );

  /// Sports Game Template
  static const GenreTemplate sports = GenreTemplate(
    genre: GameGenre.sports,
    description: 'Competitive sports simulation',
    phases: [
      TemplatePhase(
        name: 'Sport Mechanics',
        description: 'Implement sport-specific gameplay',
        tasks: [
          'Movement physics',
          'Ball mechanics',
          'Player controls',
          'Sport rules',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Team AI',
        description: 'Implement team strategy AI',
        tasks: [
          'Team formations',
          'Player positioning',
          'Tactical decisions',
          'Opponent AI',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Match System',
        description: 'Implement match structure',
        tasks: [
          'Match timer',
          'Scoring system',
          'Period/quarters',
          'Overtime rules',
        ],
        priority: PhasePriority.critical,
      ),
      TemplatePhase(
        name: 'Team Management',
        description: 'Implement team building',
        tasks: [
          'Player roster',
          'Trading system',
          'Training',
          'Team upgrades',
        ],
        priority: PhasePriority.high,
      ),
    ],
    coreMechanics: ['sport_physics', 'team_ai', 'match_system'],
    requiredSystems: ['ai', 'physics', 'ui', 'network'],
    estimatedDevelopmentTime: Duration(hours: 95),
  );

  /// Get template by genre
  static GenreTemplate? getTemplate(GameGenre genre) {
    switch (genre) {
      case GameGenre.action:
        return action;
      case GameGenre.strategy:
        return strategy;
      case GameGenre.rolePlaying:
        return rolePlaying;
      case GameGenre.simulation:
        return simulation;
      case GameGenre.adventure:
        return adventure;
      case GameGenre.sessionBattle:
        return sessionBattle;
      case GameGenre.puzzle:
        return puzzle;
      case GameGenre.sports:
        return sports;
    }
  }

  /// Get all available genres
  static List<GameGenre> getAllGenres() => GameGenre.values;

  /// Classify a game description into a genre
  static GameGenre classifyDescription(String description) {
    final lowerDesc = description.toLowerCase();

    // Session battle keywords
    if (_containsAny(lowerDesc, [
      'session',
      'battle',
      'elixir',
      'card',
      'multiplayer',
      'versus',
      'supercell',
    ])) {
      return GameGenre.sessionBattle;
    }

    // Action keywords
    if (_containsAny(lowerDesc, [
      'action',
      'combat',
      'shooter',
      'fighting',
      'platformer',
    ])) {
      return GameGenre.action;
    }

    // Strategy keywords
    if (_containsAny(lowerDesc, [
      'strategy',
      'rts',
      'resource',
      'building',
      'colony',
    ])) {
      return GameGenre.strategy;
    }

    // RPG keywords
    if (_containsAny(lowerDesc, [
      'rpg',
      'role-playing',
      'quest',
      'level',
      'character',
    ])) {
      return GameGenre.rolePlaying;
    }

    // Simulation keywords
    if (_containsAny(lowerDesc, [
      'simulation',
      'sim',
      'tycoon',
      'management',
      'colony',
    ])) {
      return GameGenre.simulation;
    }

    // Adventure keywords
    if (_containsAny(lowerDesc, [
      'adventure',
      'story',
      'exploration',
      'narrative',
    ])) {
      return GameGenre.adventure;
    }

    // Puzzle keywords
    if (_containsAny(lowerDesc, [
      'puzzle',
      'match',
      'brain',
      'logic',
    ])) {
      return GameGenre.puzzle;
    }

    // Sports keywords
    if (_containsAny(lowerDesc, [
      'sport',
      'soccer',
      'basketball',
      'football',
      'racing',
    ])) {
      return GameGenre.sports;
    }

    // Default to session battle for MG-0023
    return GameGenre.sessionBattle;
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
