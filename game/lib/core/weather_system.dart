import 'dart:async';
import 'dart:math';
import 'game_state.dart';

/// 날씨 및 재해 시스템 - emergent gameplay 유도
class WeatherSystem {
  final Random _rng = Random();
  WeatherType _currentWeather = WeatherType.clear;
  double _weatherIntensity = 0.0;
  Timer? _weatherTimer;
  final List<WeatherEvent> _activeEvents = [];

  WeatherType get currentWeather => _currentWeather;
  double get weatherIntensity => _weatherIntensity;
  List<WeatherEvent> get activeEvents => List.unmodifiable(_activeEvents);

  /// 날씨 시스템 시작
  void start() {
    // Start with clear weather for predictable initial state
    _currentWeather = WeatherType.clear;
    _weatherIntensity = 0.0;
    _weatherTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _changeWeather();
      _maybeTriggerEvent();
    });
  }

  /// 날씨 변경
  void _changeWeather() {
    final roll = _rng.nextDouble();

    if (roll < 0.5) {
      _currentWeather = WeatherType.clear;
      _weatherIntensity = 0.0;
    } else if (roll < 0.7) {
      _currentWeather = WeatherType.solarFlare;
      _weatherIntensity = 0.3 + _rng.nextDouble() * 0.4;
    } else if (roll < 0.85) {
      _currentWeather = WeatherType.dustStorm;
      _weatherIntensity = 0.2 + _rng.nextDouble() * 0.5;
    } else if (roll < 0.95) {
      _currentWeather = WeatherType.meteorShower;
      _weatherIntensity = 0.4 + _rng.nextDouble() * 0.6;
    } else {
      _currentWeather = WeatherType.cosmicStorm;
      _weatherIntensity = 0.6 + _rng.nextDouble() * 0.4;
    }
  }

  /// 랜덤 이벤트 트리거
  void _maybeTriggerEvent() {
    if (_rng.nextDouble() < 0.2) {
      final event = _generateRandomEvent();
      _activeEvents.add(event);
    }
  }

  /// 랜덤 이벤트 생성
  WeatherEvent _generateRandomEvent() {
    const types = WeatherEventType.values;
    final type = types[_rng.nextInt(types.length)];
    const baseDuration = Duration(seconds: 10);

    return WeatherEvent(
      type: type,
      severity: _rng.nextDouble(),
      duration: baseDuration + Duration(seconds: _rng.nextInt(20)),
      description: _getEventDescription(type),
    );
  }

  String _getEventDescription(WeatherEventType type) {
    switch (type) {
      case WeatherEventType.powerSurge:
        return 'Power Surge! Energy production +50% for 15s';
      case WeatherEventType.oxygenLeak:
        return 'Oxygen Leak! -20 oxygen over time';
      case WeatherEventType.resourceBounty:
        return 'Resource Bounty! +30 of all resources';
      case WeatherEventType.equipmentFailure:
        return 'Equipment Failure! Random building disabled';
    }
  }

  /// 날씨 효과를 게임 상태에 적용
  void applyWeatherEffects(GameState state) {
    switch (_currentWeather) {
      case WeatherType.clear:
        break;
      case WeatherType.solarFlare:
        // 태양풍: 에너지 생산 증가
        state.applyEventEffect({'energy': 0.5 * _weatherIntensity});
        break;
      case WeatherType.dustStorm:
        // 먼지 폭풍: 모든 생산 감소
        state.applyEventEffect({'energy': -0.2 * _weatherIntensity});
        break;
      case WeatherType.meteorShower:
        // 운석우: 철 추가, 일부 건물 손상 가능성
        if (_rng.nextDouble() < 0.1 * _weatherIntensity) {
          state.applyEventEffect({'iron': 20});
        }
        break;
      case WeatherType.cosmicStorm:
        // 우주 폭풍: 모든 자원 감소
        state.applyEventEffect({
          'energy': -0.3 * _weatherIntensity,
          'oxygen': -0.2 * _weatherIntensity,
        });
        break;
    }
  }

  /// 활성 이벤트 적용
  void applyActiveEvents(GameState state) {
    _activeEvents.removeWhere((event) {
      final isExpired = DateTime.now().isAfter(event.endTime);

      if (!isExpired) {
        event.apply(state);
      }

      return isExpired;
    });
  }

  void dispose() {
    _weatherTimer?.cancel();
  }
}

/// 날씨 타입
enum WeatherType {
  clear,
  solarFlare,
  dustStorm,
  meteorShower,
  cosmicStorm,
}

/// 날씨 이벤트 타입
enum WeatherEventType {
  powerSurge,
  oxygenLeak,
  resourceBounty,
  equipmentFailure,
}

/// 날씨 이벤트
class WeatherEvent {
  final WeatherEventType type;
  final double severity;
  final Duration duration;
  final String description;
  late final DateTime endTime;

  WeatherEvent({
    required this.type,
    required this.severity,
    required this.duration,
    required this.description,
  }) {
    endTime = DateTime.now().add(duration);
  }

  void apply(GameState state) {
    switch (type) {
      case WeatherEventType.powerSurge:
        state.applyEventEffect({'energy': 0.5});
        break;
      case WeatherEventType.oxygenLeak:
        state.applyEventEffect({'oxygen': -0.2});
        break;
      case WeatherEventType.resourceBounty:
        state.applyEventEffect({
          'iron': 30,
          'water': 30,
          'food': 30,
        });
        break;
      case WeatherEventType.equipmentFailure:
        // 랜덤 건물 비활성화 (구현 필요)
        break;
    }
  }
}
