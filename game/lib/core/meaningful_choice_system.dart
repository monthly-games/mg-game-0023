import 'dart:async';
import 'dart:math';

/// 흥미로운 결정을 유도하는 시스템
/// 상충하는 목표, 불확실성, 되돌릴 수 없는 선택
class MeaningfulChoiceSystem {
  final Random _rng = Random();
  final List<ChoiceEvent> _activeChoices = [];
  Timer? _choiceTimer;
  int _nextId = 0;

  List<ChoiceEvent> get activeChoices => List.unmodifiable(_activeChoices);

  void start() {
    // 즉시 하나의 선택 생성 (테스트용)
    _generateChoice();
    // 주기적으로 의미 있는 선택 제시
    _choiceTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_rng.nextDouble() < 0.3) {
        _generateChoice();
      }
    });
  }

  void _generateChoice() {
    const types = ChoiceType.values;
    final type = types[_rng.nextInt(types.length)];
    const choiceDuration = Duration(seconds: 30);

    final choice = ChoiceEvent(
      id: 'choice_${_nextId++}',
      type: type,
      title: _getTitle(type),
      description: _getDescription(type),
      options: _getOptions(type),
      duration: choiceDuration,
    );

    _activeChoices.add(choice);
  }

  String _getTitle(ChoiceType type) {
    switch (type) {
      case ChoiceType.resourceVsSurvival:
        return 'Resource Discovery';
      case ChoiceType.shortTermVsLongTerm:
        return 'Trade Offer';
      case ChoiceType.riskVsReward:
        return 'Dangerous Opportunity';
      case ChoiceType.moralDilemma:
        return 'Colony Ethics';
    }
  }

  String _getDescription(ChoiceType type) {
    switch (type) {
      case ChoiceType.resourceVsSurvival:
        return 'A rich mineral deposit found, but mining will damage life support.';
      case ChoiceType.shortTermVsLongTerm:
        return 'Trading ship offers emergency supplies for future favors.';
      case ChoiceType.riskVsReward:
        return 'Ancient technology discovered. Could be valuable or dangerous.';
      case ChoiceType.moralDilemma:
        return 'A stranger arrives seeking refuge. Resources are scarce.';
    }
  }

  List<ChoiceOption> _getOptions(ChoiceType type) {
    switch (type) {
      case ChoiceType.resourceVsSurvival:
        return [
          ChoiceOption(
            title: 'Mine the deposit',
            consequences: {'iron': 100, 'oxygen': -30},
            description: '+100 Iron, -30 Oxygen',
            isReversible: false,
          ),
          ChoiceOption(
            title: 'Preserve life support',
            consequences: {'oxygen': 20},
            description: '+20 Oxygen, lose resources',
            isReversible: false,
          ),
        ];
      case ChoiceType.shortTermVsLongTerm:
        return [
          ChoiceOption(
            title: 'Accept trade',
            consequences: {'food': 50, 'research': -20},
            description: '+50 Food now, -20 Research',
            isReversible: false,
          ),
          ChoiceOption(
            title: 'Decline politely',
            consequences: {'research': 10},
            description: '+10 Research, nothing now',
            isReversible: false,
          ),
        ];
      case ChoiceType.riskVsReward:
        return [
          ChoiceOption(
            title: 'Activate technology',
            isRandom: true,
            consequences: {},
            description: 'Random outcome (could be great or terrible)',
            isReversible: false,
          ),
          ChoiceOption(
            title: 'Leave it alone',
            isRandom: false,
            consequences: {},
            description: 'Safe, no reward',
            isReversible: false,
          ),
        ];
      case ChoiceType.moralDilemma:
        return [
          ChoiceOption(
            title: 'Welcome them',
            consequences: {'population': 1, 'food': -20},
            description: '+1 Colonist, -20 Food',
            isReversible: false,
          ),
          ChoiceOption(
            title: 'Turn them away',
            consequences: {'morale': -10},
            description: 'Save resources, colony morale drops',
            isReversible: false,
          ),
        ];
    }
  }

  /// 선택을 하고 결과 반환
  Map<String, double> makeChoice(String choiceId, int optionIndex) {
    final choice = _activeChoices.cast<ChoiceEvent?>().firstWhere(
      (c) => c?.id == choiceId,
      orElse: () => null,
    );

    if (choice == null) return {};

    final option = choice.options[optionIndex];
    _activeChoices.remove(choice);

    // 랜덤 결과 처리
    if (option.isRandom) {
      return _getRandomOutcome();
    }

    return option.consequences;
  }

  Map<String, double> _getRandomOutcome() {
    final roll = _rng.nextDouble();

    if (roll < 0.3) {
      // 나쁜 결과
      return {'energy': -50, 'oxygen': -30};
    } else if (roll < 0.7) {
      // 보통 결과
      return {'energy': 20, 'research': 10};
    } else {
      // 훌륭한 결과
      return {'energy': 100, 'research': 50, 'food': 30};
    }
  }

  void dispose() {
    _choiceTimer?.cancel();
  }
}

/// 선택 이벤트
class ChoiceEvent {
  final String id;
  final ChoiceType type;
  final String title;
  final String description;
  final List<ChoiceOption> options;
  final Duration duration;
  late final DateTime expiryTime;

  ChoiceEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.options,
    required this.duration,
  }) {
    expiryTime = DateTime.now().add(duration);
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// 선택 옵션
class ChoiceOption {
  final String title;
  final Map<String, double> consequences;
  final String description;
  final bool isReversible;
  final bool isRandom;

  ChoiceOption({
    required this.title,
    required this.consequences,
    required this.description,
    required this.isReversible,
    this.isRandom = false,
  });
}

/// 선택 타입
enum ChoiceType {
  resourceVsSurvival,
  shortTermVsLongTerm,
  riskVsReward,
  moralDilemma,
}
