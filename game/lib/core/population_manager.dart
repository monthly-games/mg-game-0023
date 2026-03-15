import 'package:flutter/foundation.dart';

/// Manages colony population
class PopulationManager extends ChangeNotifier {
  int _currentPopulation = 0;
  int _maxPopulation = 10;

  int get currentPopulation => _currentPopulation;
  int get maxPopulation => _maxPopulation;

  void addPopulation(int amount) {
    _currentPopulation = (_currentPopulation + amount).clamp(0, _maxPopulation);
    notifyListeners();
  }

  void setMaxPopulation(int max) {
    _maxPopulation = max;
    notifyListeners();
  }
}
