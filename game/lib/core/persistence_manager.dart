import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

class PersistenceManager {
  static const String _paramKey = 'colony_frontier_save_v1';

  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_paramKey, jsonString);
  }

  Future<bool> loadGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_paramKey);

    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString);
        state.loadFromJson(jsonMap);
        return true;
      } catch (e) {
        // Handle corruption or version mismatch
        return false;
      }
    }
    return false;
  }

  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_paramKey);
  }
}
