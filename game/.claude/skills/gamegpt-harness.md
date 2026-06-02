# GameGPT Production Harness

> Production automation for game development with dual collaboration, layered approach, and code decoupling.

## Overview

Based on the GameGPT paper (https://arxiv.org/abs/2310.08067), this skill implements a multi-agent collaborative framework for automated game development. It provides:

- **Dual Collaboration**: LLM + expert model collaboration for accuracy
- **Layered Approach**: Pre-defined templates and lexicons for precision
- **Code Decoupling**: Break large code into small, precise snippets
- **Redundancy Elimination**: Detect and remove duplicate tasks/code
- **Hallucination Detection**: Identify unrealistic requirements

## Files

- `lib/harness/game_production_harness.dart` - Main orchestration system
- `lib/harness/genre_templates.dart` - Genre-specific plan templates
- `lib/harness/task_lexicon.dart` - Task classification lexicon
- `lib/harness/code_lexicon.dart` - Code snippet templates
- `lib/harness/hallucination_detector.dart` - Hallucination detection

## Quick Start

```dart
import 'package:game/harness/game_production_harness.dart';

void main() async {
  final harness = GameProductionHarness();

  final request = GameDevelopmentRequest(
    gameName: 'My Game',
    description: 'A session-based card battle game',
  );

  final result = await harness.executePipeline(request);

  if (result.success) {
    print('Success rate: ${result.summary.successRate}');
  }
}
```

## Test Coverage

Run tests with: `flutter test test/harness/gamegpt_harness_test.dart`

**30 tests covering:**
- Phase 1: Planning (genre classification, templates)
- Phase 2: Task Classification (type detection, redundancy)
- Phase 3: Code Generation (snippets, lexicon)
- Phase 4: Hallucination Detection (validation, warnings)
- Integration Tests (full pipeline, templates, coverage)

## Supported Genres

- Action, Strategy, Role-Playing, Simulation, Adventure
- **Session Battle** (Supercell-style mobile games)
- Puzzle, Sports

## Key Concepts

### Dual Collaboration

Uses execution agents (generate) and reviewer agents (validate) to reduce hallucinations and redundancy.

### Code Decoupling

Breaks large scripts into small snippets for better accuracy:
- `snippet_1.dart` - Elixir system
- `snippet_2.dart` - Card system
- `snippet_3.dart` - Session timer

### Hallucination Detection

Detects these patterns:
- **Impossible Features**: "instant", "perfect", "infinite"
- **Unrealistic Requirements**: "zero latency", "no memory"
- **Unknown APIs**: "magic_function", "auto_solve"
- **Placeholders**: "TODO: implement", "NotImplementedError"

## References

- Paper: https://arxiv.org/abs/2310.08067
- Guide: `docs/gamegpt_harness_guide.md`
- Tests: `test/harness/gamegpt_harness_test.dart`

---

**Maintained by:** MG-0023 Development Team
**Last Updated:** 2026-05-23
