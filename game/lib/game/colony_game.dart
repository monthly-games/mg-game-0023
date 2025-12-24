import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

class ColonyGame extends FlameGame {
  final AudioManager audio = GetIt.I<AudioManager>();

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    // Game initialization logic will go here
    try {
      // Audio managed globally
    } catch (e) {
      debugPrint("Game load error: $e");
    }
  }
}
