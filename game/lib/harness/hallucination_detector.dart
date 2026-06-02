/// Hallucination detection system for GameGPT framework
/// Based on GameGPT paper's hallucination mitigation strategies
/// Reference: https://arxiv.org/abs/2310.08067

library;

// -----------------------------------------------------------------------------
// Hallucination Detection
// -----------------------------------------------------------------------------

/// Detects and prevents hallucinations in generated content
class HallucinationDetector {
  // Random is available for future use (currently unused)
  // final Random _rng = Random();

  // Hallucination patterns to detect
  static const List<HallucinationPattern> _patterns = [
    // Impossible features
    HallucinationPattern(
      type: HallucinationType.impossibleFeature,
      keywords: ['impossible', 'instant', 'perfect', 'unlimited', 'infinite'],
      severity: HallucinationSeverity.critical,
    ),

    // Unrealistic requirements
    HallucinationPattern(
      type: HallucinationType.unrealisticRequirement,
      keywords: ['zero latency', 'no memory', 'instant load', 'infinite performance'],
      severity: HallucinationSeverity.high,
    ),

    // Unknown APIs
    HallucinationPattern(
      type: HallucinationType.unknownAPI,
      keywords: ['magic_function', 'auto_solve', 'ai_complete'],
      severity: HallucinationSeverity.high,
    ),

    // Placeholder code
    HallucinationPattern(
      type: HallucinationType.placeholder,
      keywords: ['TODO: implement', 'FIXME: implement', 'NotImplementedError'],
      severity: HallucinationSeverity.medium,
    ),

    // Unrealistic time estimates
    HallucinationPattern(
      type: HallucinationType.unrealisticTime,
      keywords: ['in 1 minute', 'instantly', 'immediately done'],
      severity: HallucinationSeverity.medium,
    ),
  ];

  /// Detect hallucinations in text
  static List<HallucinationWarning> detect(String text) {
    final warnings = <HallucinationWarning>[];
    final lowerText = text.toLowerCase();

    for (final pattern in _patterns) {
      for (final keyword in pattern.keywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          warnings.add(HallucinationWarning(
            type: pattern.type,
            severity: pattern.severity,
            message: 'Potential hallucination detected: "$keyword"',
            matchedText: keyword,
          ));
        }
      }
    }

    return warnings;
  }

  /// Check if code has hallucination indicators
  static bool hasHallucination(String code) {
    return detect(code).any((w) =>
        w.severity == HallucinationSeverity.critical ||
        w.severity == HallucinationSeverity.high);
  }

  /// Validate task requirements are realistic
  static bool areRequirementsRealistic(Map<String, dynamic> requirements) {
    // Check for unrealistic values
    if (requirements.containsKey('time_estimate')) {
      final time = requirements['time_estimate'] as int?;
      if (time != null && time < 0) return false;
    }

    if (requirements.containsKey('memory')) {
      final memory = requirements['memory'] as int?;
      if (memory != null && memory <= 0) return false;
    }

    // Check for impossible combinations
    if (requirements.containsKey('quality') &&
        requirements.containsKey('time_estimate')) {
      final quality = requirements['quality'] as String?;
      final time = requirements['time_estimate'] as int?;

      if (quality == 'perfect' && time != null && time < 60) {
        // Perfect quality in under a minute is unrealistic
        return false;
      }
    }

    return true;
  }
}

// -----------------------------------------------------------------------------
// Hallucination Types
// -----------------------------------------------------------------------------

enum HallucinationType {
  impossibleFeature,
  unrealisticRequirement,
  unknownAPI,
  placeholder,
  unrealisticTime,
  dependencyIssue,
}

enum HallucinationSeverity {
  low,
  medium,
  high,
  critical,
}

// -----------------------------------------------------------------------------
// Data Models
// -----------------------------------------------------------------------------

class HallucinationPattern {
  final HallucinationType type;
  final List<String> keywords;
  final HallucinationSeverity severity;

  const HallucinationPattern({
    required this.type,
    required this.keywords,
    required this.severity,
  });
}

class HallucinationWarning {
  final HallucinationType type;
  final HallucinationSeverity severity;
  final String message;
  final String matchedText;

  const HallucinationWarning({
    required this.type,
    required this.severity,
    required this.message,
    required this.matchedText,
  });

  @override
  String toString() =>
      '[$severity] $message (matched: "$matchedText")';
}

// -----------------------------------------------------------------------------
// Hallucination Validator
// -----------------------------------------------------------------------------

/// Validates generated content against hallucinations
class HallucinationValidator {
  final List<HallucinationWarning> _warnings = [];
  int _validatedCount = 0;
  int _rejectedCount = 0;

  List<HallucinationWarning> get warnings => List.unmodifiable(_warnings);
  int get validatedCount => _validatedCount;
  int get rejectedCount => _rejectedCount;
  double get rejectionRate =>
      _validatedCount > 0 ? _rejectedCount / _validatedCount : 0;

  /// Validate a generated task
  ValidationResult validateTask(GeneratedTask task) {
    _validatedCount++;

    final contentWarnings = HallucinationDetector.detect(task.description);
    final requirementsWarnings = HallucinationDetector.detect(
      task.requirements.toString(),
    );

    final allWarnings = [...contentWarnings, ...requirementsWarnings];

    if (allWarnings.any((w) =>
        w.severity == HallucinationSeverity.critical)) {
      _rejectedCount++;
      _warnings.addAll(allWarnings);
      return ValidationResult.rejected(allWarnings);
    }

    if (allWarnings.any((w) =>
        w.severity == HallucinationSeverity.high)) {
      _warnings.addAll(allWarnings);
      return ValidationResult.needsReview(allWarnings);
    }

    if (allWarnings.isNotEmpty) {
      _warnings.addAll(allWarnings);
      return ValidationResult.warning(allWarnings);
    }

    return ValidationResult.valid();
  }

  /// Validate code snippet
  ValidationResult validateCode(String code) {
    _validatedCount++;

    final warnings = HallucinationDetector.detect(code);

    if (HallucinationDetector.hasHallucination(code)) {
      _rejectedCount++;
      _warnings.addAll(warnings);
      return ValidationResult.rejected(warnings);
    }

    if (warnings.isNotEmpty) {
      _warnings.addAll(warnings);
      return ValidationResult.warning(warnings);
    }

    return ValidationResult.valid();
  }

  void reset() {
    _warnings.clear();
    _validatedCount = 0;
    _rejectedCount = 0;
  }
}

// -----------------------------------------------------------------------------
// Validation Result
// -----------------------------------------------------------------------------

class ValidationResult {
  final ValidationStatus status;
  final List<HallucinationWarning> warnings;

  const ValidationResult({
    required this.status,
    this.warnings = const [],
  });

  factory ValidationResult.valid() => const ValidationResult(
    status: ValidationStatus.valid,
  );

  factory ValidationResult.warning(List<HallucinationWarning> warnings) =>
      ValidationResult(
        status: ValidationStatus.warning,
        warnings: warnings,
      );

  factory ValidationResult.needsReview(List<HallucinationWarning> warnings) =>
      ValidationResult(
        status: ValidationStatus.needsReview,
        warnings: warnings,
      );

  factory ValidationResult.rejected(List<HallucinationWarning> warnings) =>
      ValidationResult(
        status: ValidationStatus.rejected,
        warnings: warnings,
      );

  bool get isValid => status == ValidationStatus.valid;
  bool get isRejected => status == ValidationStatus.rejected;
  bool get needsReview => status == ValidationStatus.needsReview;
}

enum ValidationStatus {
  valid,
  warning,
  needsReview,
  rejected,
}

// -----------------------------------------------------------------------------
// Generated Task Model
// -----------------------------------------------------------------------------

class GeneratedTask {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> requirements;
  final String? code;

  const GeneratedTask({
    required this.id,
    required this.name,
    required this.description,
    this.requirements = const {},
    this.code,
  });
}
