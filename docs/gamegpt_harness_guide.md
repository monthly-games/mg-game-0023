# GameGPT Production Harness Guide

**Based on:** GameGPT: Multi-agent Collaborative Framework for Game Development
**Paper:** https://arxiv.org/abs/2310.08067
**Version:** 1.0
**Date:** 2026-05-23

---

## Overview

The GameGPT Production Harness is a Flutter/Dart implementation of the GameGPT framework for automated mobile game development. This harness provides:

- **Dual Collaboration**: LLM + expert model collaboration
- **Layered Approach**: Pre-defined templates and lexicons for accuracy
- **Code Decoupling**: Break large code into small, precise snippets
- **Redundancy Elimination**: Detect and remove duplicate tasks/code
- **Hallucination Detection**: Identify unrealistic requirements

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Game Production Harness                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Phase 1   │ -> │   Phase 2   │ -> │   Phase 3   │     │
│  │  Planning   │    │Classification│    │ Code Gen   │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                   │                   │           │
│         v                   v                   v           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Reviewer  │    │   Reviewer  │    │   Reviewer  │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                              │
│                           ↓                                 │
│                  ┌─────────────┐                            │
│                  │  Phase 4    │                            │
│                  │  Execution  │                            │
│                  └─────────────┘                            │
│                           ↓                                 │
│                  ┌─────────────┐                            │
│                  │  Phase 5    │                            │
│                  │   Summary   │                            │
│                  └─────────────┘                            │
└─────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
lib/harness/
├── game_production_harness.dart    # Main orchestration system
├── genre_templates.dart             # Genre-specific plan templates
├── task_lexicon.dart                # Task classification lexicon
├── code_lexicon.dart                # Code snippet templates
└── hallucination_detector.dart      # Hallucination detection
```

---

## Usage Examples

### Basic Usage

```dart
import 'package:game/harness/game_production_harness.dart';

void main() async {
  // Create the harness
  final harness = GameProductionHarness();

  // Define your game request
  final request = GameDevelopmentRequest(
    gameName: 'Colony Frontier',
    description: 'A session-based colony building game with real-time battles',
    requirements: {
      'genre': 'session_battle',
      'platform': 'mobile',
      'session_length': '3-5 minutes',
    },
  );

  // Execute the development pipeline
  final result = await harness.executePipeline(request);

  // Check results
  if (result.success) {
    print('Tasks completed: ${result.summary.successfulTasks}/${result.summary.totalTasks}');
    print('Success rate: ${(result.summary.successRate * 100).toInt()}%');
  } else {
    print('Errors: ${result.summary.errors}');
  }

  // View logs
  for (final log in harness.logs) {
    print(log);
  }
}
```

### Using Genre Templates

```dart
import 'package:game/harness/genre_templates.dart';

// Classify your game genre
final genre = GenreTemplates.classifyDescription(
  'A fast-paced card battle game with elixir system'
);
print('Detected genre: $genre'); // GameGenre.sessionBattle

// Get the template
final template = GenreTemplates.getTemplate(genre);
if (template != null) {
  print('Estimated development time: ${template.estimatedDevelopmentTime}');
  print('Core mechanics: ${template.coreMechanics}');

  // Get phases
  for (final phase in template.phases) {
    print('Phase: ${phase.name} (Priority: ${phase.priority})');
    for (final task in phase.tasks) {
      print('  - $task');
    }
  }
}
```

### Task Classification

```dart
import 'package:game/harness/task_lexicon.dart';

// Classify a task
final taskType = TaskKeywords.classify('Implement elixir generation system');
print('Task type: $taskType'); // GameTaskType.currency

// Check for redundancy
final tasks = [
  'Implement player movement',
  'Create player character movement',
];

final redundant = RedundancyDetector.findRedundantTasks(tasks);
for (final pair in redundant) {
  print('Redundant: ${pair.task1} <-> ${pair.task2}');
}
```

### Code Generation with Lexicon

```dart
import 'package:game/harness/code_lexicon.dart';

// Search for code snippets
final elixirSnippets = GameCodeLexicon.search('elixir');
for (final snippet in elixirSnippets) {
  print('Found: ${snippet.name}');
  print(snippet.code);
}

// Get snippets by category
final uiSnippets = GameCodeLexicon.getByCategory('ui');
```

### Hallucination Detection

```dart
import 'package:game/harness/hallucination_detector.dart';

// Detect hallucinations in text
final text = 'Implement impossible instant loading with zero memory';
final warnings = HallucinationDetector.detect(text);

for (final warning in warnings) {
  print('WARNING: ${warning.message}');
  print('Severity: ${warning.severity}');
}

// Validate requirements
final requirements = {
  'time_estimate': -10, // Invalid!
};

final valid = HallucinationDetector.areRequirementsRealistic(requirements);
print('Requirements valid: $valid'); // false
```

---

## Supported Genres

| Genre | Description | Core Mechanics |
|-------|-------------|----------------|
| **Action** | Fast-paced combat and reflexes | Player controller, combat, physics, AI |
| **Strategy** | Tactical resource management | Resources, buildings, units, tech tree |
| **Role-Playing** | Story-driven character progression | Character, inventory, quests, dialogue |
| **Simulation** | Realistic world simulation | Simulation loop, entities, time, save/load |
| **Adventure** | Story and exploration focus | Story, exploration, puzzles, interaction |
| **Session Battle** | Short intense multiplayer battles | Elixir, cards, timer, matchmaking |
| **Puzzle** | Brain-teasing puzzles | Puzzle logic, levels, scoring |
| **Sports** | Competitive sports simulation | Sport physics, team AI, match system |

---

## Task Types

The harness recognizes 30+ task types across categories:

### Core Systems
- `gameplayMechanic` - Core gameplay implementation
- `physicsSystem` - Physics and collision
- `inputSystem` - Input handling
- `cameraSystem` - Camera controls

### UI/UX
- `uiScreen` - Full screen interfaces
- `uiWidget` - Individual UI components
- `hud` - Heads-up displays
- `menu` - Menu systems

### Audio/Visual
- `soundEffect` - SFX implementation
- `music` - Music system
- `visualEffect` - VFX and particles
- `animation` - Animation systems

### Network
- `multiplayer` - Multiplayer features
- `matchmaking` - Player matching
- `leaderboards` - Ranking systems

### Economy
- `currency` - Currency systems (elixir, gold, etc.)
- `shop` - In-game stores
- `inventory` - Item management

---

## Key Concepts

### 1. Dual Collaboration

The harness uses two types of agents:

1. **Execution Agents**: Generate plans, classify tasks, write code
2. **Reviewer Agents**: Validate and correct execution agent outputs

This reduces both hallucination and redundancy.

### 2. Layered Approach

Three layers work together:

1. **Templates**: Pre-built genre-specific plans
2. **Lexicons**: In-house vocabulary for tasks and code
3. **Validation**: Reviewer agents ensure quality

### 3. Code Decoupling

Large code is broken into small snippets:

```
Monolithic Script (High Hallucination Risk)
         ↓
    Decouple
         ↓
Multiple Small Snippets (Low Risk)
- snippet_1.dart
- snippet_2.dart
- snippet_3.dart
```

### 4. K-Candidate Selection

For each task, generate K=3 candidates:
1. Generate multiple versions
2. Test in virtual environment
3. User selects best option
4. Only execute selected version

---

## Hallucination Detection

The harness detects these hallucination types:

| Type | Example Keywords | Severity |
|------|------------------|----------|
| Impossible Feature | impossible, instant, perfect | Critical |
| Unrealistic Requirement | zero latency, no memory | High |
| Unknown API | magic_function, auto_solve | High |
| Placeholder | TODO: implement | Medium |
| Unrealistic Time | in 1 minute | Medium |

---

## Redundancy Detection

The harness identifies redundant tasks using Jaccard similarity:

```
Similarity = (Intersection / Union) × 100%

Task 1: "Implement player movement system"
Task 2: "Create player character movement"
Intersection: {player, movement}
Union: {implement, player, movement, system, create, character}
Similarity: ~50% (Not redundant)

Task 1: "Implement player movement"
Task 2: "Create player movement"
Intersection: {player, movement}
Union: {implement, player, movement, create}
Similarity: ~75% (REDUNDANT)
```

---

## Phase-by-Phase Process

### Phase 1: Planning

1. **Genre Classification** - Detect game genre from description
2. **Template Application** - Apply genre-specific plan template
3. **Plan Generation** - Create task list from template
4. **Plan Review** - Reviewer validates and refines plan

### Phase 2: Task Classification

1. **Task Type Detection** - Classify each task by type
2. **Argument Extraction** - Extract required arguments using templates
3. **Dependency Analysis** - Identify task dependencies
4. **Execution Ordering** - Create valid execution sequence

### Phase 3: Code Generation

1. **Decoupling** - Break code into small snippets
2. **In-Context Learning** - Use lexicon snippets as examples
3. **K-Candidate Generation** - Generate 3 code candidates
4. **Code Review** - Reviewer validates generated code

### Phase 4: Execution

1. **Dependency Resolution** - Execute in correct order
2. **Code Execution** - Run generated code
3. **Error Collection** - Gather execution logs
4. **Traceback Analysis** - Identify issues

### Phase 5: Summary

1. **Result Compilation** - Combine all results
2. **Statistics Calculation** - Compute success metrics
3. **Error Reporting** - List all failures
4. **User Feedback** - Present summary to user

---

## Integration with MG-0023

The harness is designed for use with MG-0023 (Colony Frontier):

```dart
// MG-0023 specific request
final request = GameDevelopmentRequest(
  gameName: 'Colony Frontier',
  description: '''
    A session-based colony building and battle game.
    Features:
    - 3-minute battle sessions
    - Elixir-based resource system
    - Card-based combat
    - Real-time matchmaking
    - Trophy progression
  ''',
  requirements: {
    'genre': 'session_battle',
    'supercell_style': true,
    'session_length': 180, // seconds
    'max_elixir': 10,
    'elixir_regen_rate': 2.8, // seconds per elixir
    'card_hand_size': 4,
  },
);
```

---

## Best Practices

### 1. Be Specific in Descriptions

**Bad:**
```dart
description: 'A fun game'
```

**Good:**
```dart
description: 'A session-based strategy game with elixir resource system, card combat, and real-time multiplayer'
```

### 2. Use Genre Keywords

Include genre-specific keywords to improve classification:
- `session`, `battle`, `elixir` → Session Battle
- `colony`, `resource`, `building` → Strategy
- `character`, `quest`, `level` → Role-Playing

### 3. Provide Realistic Requirements

**Bad:**
```dart
requirements: {
  'time': 'instant',
  'quality': 'perfect',
}
```

**Good:**
```dart
requirements: {
  'time_estimate': 80, // hours
  'quality': 'production',
  'testing': 'included',
}
```

### 4. Review Generated Plans

Always review the generated plan before execution:
1. Check for redundant tasks
2. Verify task dependencies
3. Confirm execution order
4. Validate time estimates

---

## Troubleshooting

### Issue: Wrong Genre Detection

**Solution:** Add genre-specific keywords to description:
```dart
description: 'A fast-paced card battle game with elixir system'
// "card", "battle", "elixir" trigger session_battle genre
```

### Issue: Too Many Redundant Tasks

**Solution:** Review plan and merge similar tasks manually before execution.

### Issue: Hallucination Warnings

**Solution:** Modify requirements to be more realistic:
```dart
// Instead of: 'instant loading'
// Use: 'fast loading (< 2 seconds)'
```

---

## References

- **Paper:** GameGPT: Multi-agent Collaborative Framework for Game Development
- **arXiv:** https://arxiv.org/abs/2310.08067
- **PDF:** https://arxiv.org/pdf/2310.08067
- **Authors:** Dake Chen, Haoyang Zhang, Hanbin Wang, et al.
- **Submitted:** October 12, 2023
- **Revised:** September 7, 2025

---

**Maintained by:** MG-0023 Development Team
**Last Updated:** 2026-05-23
