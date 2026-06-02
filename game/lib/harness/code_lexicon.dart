/// Code snippet lexicon for GameGPT framework
/// Based on Section 2.5: Code Generation with In-Context Learning
/// Reference: https://arxiv.org/abs/2310.08067
///
/// This in-house lexicon provides code snippets for game development
/// to improve code generation accuracy and reduce hallucination.

library;

// -----------------------------------------------------------------------------
// Code Snippet Lexicon
// -----------------------------------------------------------------------------

/// Code snippet with metadata
class CodeSnippet {
  final String id;
  final String name;
  final String category;
  final String language;
  final String code;
  final String description;
  final List<String> tags;
  final List<String> dependencies;

  const CodeSnippet({
    required this.id,
    required this.name,
    required this.category,
    required this.language,
    required this.code,
    required this.description,
    this.tags = const [],
    this.dependencies = const [],
  });
}

/// In-house code lexicon for game development
class GameCodeLexicon {
  static const List<CodeSnippet> snippets = [
    // -------------------------------------------------------------------------
    // Flutter/Gameplay Snippets
    // -------------------------------------------------------------------------
    CodeSnippet(
      id: 'flutter_game_widget',
      name: 'Game Widget Base',
      category: 'gameplay',
      language: 'dart',
      description: 'Base widget for game screens with update loop',
      code: '''
class GameWidget extends StatefulWidget {
  final Widget Function(BuildContext) builder;

  const GameWidget({required this.builder, super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    setState(() {
      _elapsed = elapsed;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
''',
      tags: ['flutter', 'widget', 'game', 'ticker'],
    ),

    CodeSnippet(
      id: 'resource_manager',
      name: 'Resource Manager',
      category: 'gameplay',
      language: 'dart',
      description: 'Manages game resources with change notifications',
      code: '''
class ResourceManager extends ChangeNotifier {
  final Map<String, double> _resources = {};

  double get(String resource) => _resources[resource] ?? 0;

  bool has(String resource, double amount) =>
      get(resource) >= amount;

  bool consume(String resource, double amount) {
    if (!has(resource, amount)) return false;
    _resources[resource] = get(resource) - amount;
    notifyListeners();
    return true;
  }

  void add(String resource, double amount) {
    _resources[resource] = get(resource) + amount;
    notifyListeners();
  }

  void set(String resource, double amount) {
    _resources[resource] = amount;
    notifyListeners();
  }
}
''',
      tags: ['resource', 'manager', 'economy'],
    ),

    // -------------------------------------------------------------------------
    // Session Battle Snippets (Supercell Style)
    // -------------------------------------------------------------------------
    CodeSnippet(
      id: 'elixir_system',
      name: 'Elixir System',
      category: 'session_battle',
      language: 'dart',
      description: 'Elixir-based resource system for session battles',
      code: '''
class ElixirSystem extends ChangeNotifier {
  int _elixir = 4;
  int _maxElixir = 10;
  Timer? _regenTimer;

  int get elixir => _elixir;
  int get maxElixir => _maxElixir;
  double get regenRate => 2.8; // seconds per elixir

  bool get isFull => _elixir >= _maxElixir;

  void start() {
    _regenTimer = Timer.periodic(
      Duration(milliseconds: (regenRate * 1000).toInt()),
      (_) => _regenerate(),
    );
  }

  void _regenerate() {
    if (_elixir < _maxElixir) {
      _elixir++;
      notifyListeners();
    }
  }

  bool consume(int amount) {
    if (_elixir < amount) return false;
    _elixir -= amount;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _regenTimer?.cancel();
    super.dispose();
  }
}
''',
      tags: ['elixir', 'resource', 'supercell', 'session'],
    ),

    CodeSnippet(
      id: 'battle_card',
      name: 'Battle Card',
      category: 'session_battle',
      language: 'dart',
      description: 'Card model for session-based battles',
      code: '''
class BattleCard {
  final String id;
  final String name;
  final int elixirCost;
  final CardType type;
  final int damage;
  final String description;

  const BattleCard({
    required this.id,
    required this.name,
    required this.elixirCost,
    required this.type,
    required this.damage,
    required this.description,
  });

  bool canPlay(int availableElixir) =>
      availableElixir >= elixirCost;
}

enum CardType { troop, spell, building }
''',
      tags: ['card', 'battle', 'elixir'],
    ),

    CodeSnippet(
      id: 'session_timer',
      name: 'Session Timer',
      category: 'session_battle',
      language: 'dart',
      description: '3-minute session timer for battles',
      code: '''
class SessionTimer extends ChangeNotifier {
  static const int _sessionDuration = 180; // 3 minutes

  int _remaining = _sessionDuration;
  Timer? _timer;
  bool _isRunning = false;

  int get remaining => _remaining;
  bool get isRunning => _isRunning;
  bool get isOvertime => _remaining <= 0;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > 0) {
        _remaining--;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  String get formatted {
    final minutesVal = _remaining ~/ 60;
    final secondsVal = _remaining % 60;
    return "\$minutesVal:\${secondsVal.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
''',
      tags: ['timer', 'session', 'supercell'],
    ),

    // -------------------------------------------------------------------------
    // UI Snippets
    // -------------------------------------------------------------------------
    CodeSnippet(
      id: 'game_hud',
      name: 'Game HUD',
      category: 'ui',
      language: 'dart',
      description: 'Heads-up display for game screens',
      code: '''
class GameHUD extends StatelessWidget {
  final int score;
  final int health;
  final int level;

  const GameHUD({
    super.key,
    required this.score,
    required this.health,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatBar(labelVal: 'HP', value: health, max: 100),
          Text('\$score', style: _textStyle),
          Text('\$level', style: _textStyle),
        ],
      ),
    );
  }

  static const TextStyle _textStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}

class _StatBar extends StatelessWidget {
  final String labelVal;
  final int value;
  final int max;

  const _StatBar({required this.labelVal, required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('\${labelVal}: ', style: GameHUD._textStyle),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: value / max,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(
                value > 30 ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''',
      tags: ['ui', 'hud', 'flutter'],
    ),

    // -------------------------------------------------------------------------
    // Animation Snippets
    // -------------------------------------------------------------------------
    CodeSnippet(
      id: 'particle_effect',
      name: 'Particle Effect',
      category: 'vfx',
      language: 'dart',
      description: 'Simple particle system for visual effects',
      code: '''
class ParticleEffect extends StatefulWidget {
  final Offset origin;
  final Color color;
  final int particleCount;
  final Duration duration;

  const ParticleEffect({
    super.key,
    required this.origin,
    required this.color,
    this.particleCount = 20,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _generateParticles();
    _controller.forward();
  }

  void _generateParticles() {
    final random = Random();
    for (int i = 0; i < widget.particleCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 50 + random.nextDouble() * 100;
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        size: 4 + random.nextDouble() * 6,
      ));
    }
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
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            origin: widget.origin,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Offset origin;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.origin,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = 1.0 - progress;
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = origin.dx + cos(particle.angle) * distance;
      final y = origin.dy + sin(particle.angle) * distance;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
''',
      tags: ['vfx', 'particle', 'animation'],
    ),

    // -------------------------------------------------------------------------
    // Data Model Snippets
    // -------------------------------------------------------------------------
    CodeSnippet(
      id: 'building_model',
      name: 'Building Model',
      category: 'data',
      language: 'dart',
      description: 'Data model for buildings in strategy games',
      code: '''
class Building {
  final String id;
  final String name;
  final String type;
  final int gridX;
  final int gridY;
  final Map<String, int> production;
  final Map<String, int> costs;
  final int level;

  const Building({
    required this.id,
    required this.name,
    required this.type,
    required this.gridX,
    required this.gridY,
    this.production = const {},
    this.costs = const {},
    this.level = 1,
  });

  Building copyWith({
    String? id,
    String? name,
    String? type,
    int? gridX,
    int? gridY,
    Map<String, int>? production,
    Map<String, int>? costs,
    int? level,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      production: production ?? this.production,
      costs: costs ?? this.costs,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'gridX': gridX,
    'gridY': gridY,
    'production': production,
    'costs': costs,
    'level': level,
  };

  factory Building.fromJson(Map<String, dynamic> json) => Building(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    gridX: json['gridX'] as int,
    gridY: json['gridY'] as int,
    production: Map<String, int>.from(json['production'] ?? {}),
    costs: Map<String, int>.from(json['costs'] ?? {}),
    level: json['level'] as int? ?? 1,
  );
}
''',
      tags: ['model', 'building', 'strategy'],
    ),

    // -------------------------------------------------------------------------
    // Save/Load Snippets
    // -------------------------------------------------------------------------
    CodeSnippet(
      id: 'save_system',
      name: 'Save System',
      category: 'persistence',
      language: 'dart',
      description: 'Simple save/load system using shared_preferences',
      code: '''
class SaveSystem {
  static const String _saveKey = 'game_save';

  Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(_saveKey, jsonString);
  }

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }

  Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }
}
''',
      tags: ['save', 'load', 'persistence'],
    ),
  ];

  /// Get snippets by category
  static List<CodeSnippet> getByCategory(String category) {
    return snippets
        .where((s) => s.category == category)
        .toList();
  }

  /// Get snippets by tag
  static List<CodeSnippet> getByTag(String tag) {
    return snippets
        .where((s) => s.tags.contains(tag))
        .toList();
  }

  /// Get snippet by ID
  static CodeSnippet? getById(String id) {
    try {
      return snippets.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search snippets by description or tags
  static List<CodeSnippet> search(String query) {
    final lowerQuery = query.toLowerCase();
    return snippets
        .where((s) =>
            s.name.toLowerCase().contains(lowerQuery) ||
            s.description.toLowerCase().contains(lowerQuery) ||
            s.tags.any((t) => t.toLowerCase().contains(lowerQuery)))
        .toList();
  }
}
